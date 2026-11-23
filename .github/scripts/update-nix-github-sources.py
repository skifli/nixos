#!/usr/bin/env python3
"""Update stable GitHub release pins found in literal fetchFromGitHub blocks."""
import json, os, re, subprocess, urllib.error, urllib.parse, urllib.request
from pathlib import Path
ROOT = Path(__file__).resolve().parents[2]
TAG = re.compile(r"^v?\d+\.\d+(?:\.\d+){0,2}$")
FETCH = re.compile(r"\bfetchFromGitHub\s*\{")
FIELDS = {k: re.compile(r'(?m)^[ \t]*'+k+r'[ \t]*=[ \t]*"([^"]+)"[ \t]*;')
          for k in ("owner","repo","rev","tag","hash","sha256")}
VERSION = re.compile(r'(?m)^([ \t]*version[ \t]*=[ \t]*")([^"]+)(";)')
SUBMODULE = re.compile(r'(?m)^[ \t]*fetchSubmodules[ \t]*=[ \t]*true[ \t]*;')
SOURCE_ROOT = re.compile(r'sourceRoot[ \t]*=[ \t]*"\$\x7bfinalAttrs\.src\.name\}([^"]*)";')

def mask(text):
    out=list(text); i=0; mode="code"; depth=0
    while i<len(text):
        if mode=="code":
            if text.startswith("/*",i): out[i:i+2]="  "; depth=1; mode="comment"; i+=2
            elif text[i]=="#": out[i]=" "; mode="line"; i+=1
            elif text.startswith("''",i): out[i:i+2]="  "; mode="indent"; i+=2
            elif text[i]=='"': out[i]=" "; mode="double"; i+=1
            else: i+=1
        elif mode=="line":
            if text[i]=="\n": mode="code"
            else: out[i]=" "
            i+=1
        elif mode=="comment":
            if text.startswith("/*",i): out[i:i+2]="  "; depth+=1; i+=2
            elif text.startswith("*/",i):
                out[i:i+2]="  "; depth-=1; i+=2
                if depth==0: mode="code"
            else:
                if text[i]!="\n": out[i]=" "
                i+=1
        elif mode=="double":
            if text[i]=="\\":
                out[i]=" "
                if i+1<len(text):
                    if text[i+1]!="\n": out[i+1]=" "
                    i+=2
                else: i+=1
            elif text[i]=='"': out[i]=" "; mode="code"; i+=1
            else:
                if text[i]!="\n": out[i]=" "
                i+=1
        else:
            if text.startswith("'''",i): out[i:i+3]="   "; i+=3
            elif text.startswith("''",i): out[i:i+2]="  "; mode="code"; i+=2
            else:
                if text[i]!="\n": out[i]=" "
                i+=1
    return "".join(out)

def brace_pairs(text):
    stack=[]; result=[]
    for i,ch in enumerate(text):
        if ch=="{": stack.append(i)
        elif ch=="}" and stack: result.append((stack.pop(),i))
    return result

class GitHub:
    def __init__(self): self.token=os.environ.get("GITHUB_TOKEN","")
    def get(self,url):
        headers={"User-Agent":"nix-github-source-updater","Accept":"application/vnd.github+json"}
        if self.token: headers["Authorization"]="Bearer "+self.token
        with urllib.request.urlopen(urllib.request.Request(url,headers=headers),timeout=60) as r: return r.read()
    def release(self,owner,repo):
        try: return json.loads(self.get(f"https://api.github.com/repos/{owner}/{repo}/releases/latest"))
        except urllib.error.HTTPError as e:
            if e.code==404: return None
            raise
    def latest_commit(self,owner,repo):
        repository=json.loads(self.get(f"https://api.github.com/repos/{owner}/{repo}"))
        branch=repository.get("default_branch")
        if not branch: return None
        try:
            commit=json.loads(self.get(f"https://api.github.com/repos/{owner}/{repo}/commits/{urllib.parse.quote(branch,safe='')}"))
        except urllib.error.HTTPError as e:
            if e.code==404: return None
            raise
        return {"sha":commit.get("sha"),"branch":branch,"html_url":commit.get("html_url"),
                "message":commit.get("commit",{}).get("message",""),
                "date":commit.get("commit",{}).get("committer",{}).get("date","")}
    def config(self,owner,repo,ref,root,raw_ref=False):
        import io,tarfile
        from pathlib import PurePosixPath
        # Config comparison is only meaningful for sources with an explicit
        # sourceRoot; don't download an archive just to look for a root config.
        if not root: return None
        escaped=urllib.parse.quote(ref,safe="")
        url=(f"https://github.com/{owner}/{repo}/archive/{escaped}.tar.gz" if raw_ref else
             f"https://github.com/{owner}/{repo}/archive/refs/tags/{escaped}.tar.gz")
        wanted=PurePosixPath(root.lstrip("/"))/"config.json"
        with tarfile.open(fileobj=io.BytesIO(self.get(url)),mode="r:gz") as tar:
            for member in tar.getmembers():
                if not member.isfile(): continue
                parts=PurePosixPath(member.name).parts
                if (PurePosixPath(*parts[1:]) if len(parts)>1 else PurePosixPath())!=wanted: continue
                stream=tar.extractfile(member)
                if stream is None: return None
                value=json.loads(stream.read())
                return value if isinstance(value,dict) else None
        return None

def hash_for(owner,repo,revision,raw_ref=False):
    escaped=urllib.parse.quote(revision,safe="")
    url=(f"https://github.com/{owner}/{repo}/archive/{escaped}.tar.gz" if raw_ref else
         f"https://github.com/{owner}/{repo}/archive/refs/tags/{escaped}.tar.gz")
    got=subprocess.run(["nix-prefetch-url","--unpack","--type","sha256",url],check=True,capture_output=True,text=True)
    b32=next((x.strip() for x in got.stdout.splitlines() if re.fullmatch(r"[0-9a-df-np-sv-z]{52}",x.strip())),None)
    if not b32: raise RuntimeError(f"Could not read hash for {owner}/{repo}@{revision}")
    return subprocess.run(["nix","hash","to-sri","--type","sha256",b32],check=True,capture_output=True,text=True).stdout.strip()

def summarize(old,new):
    if old is None and new is None: return ["No sourceRoot config.json in either release."]
    if old is None: return ["A sourceRoot config.json was added."]
    if new is None: return ["The sourceRoot config.json was removed."]
    added=sorted(set(new)-set(old)); removed=sorted(set(old)-set(new))
    changed=sorted(k for k in set(old)&set(new) if old[k]!=new[k]); lines=[]
    if added: lines.append("Added defaults: "+", ".join(added))
    if removed: lines.append("Removed defaults: "+", ".join(removed))
    if changed: lines.append("Changed defaults: "+", ".join(changed))
    return lines or ["No default config keys or values changed."]

def inspect(path,source,gh):
    active=mask(source); pairs=brace_pairs(active); updates=[]; skipped=[]
    for call in FETCH.finditer(active):
        opening=active.find("{",call.start(),call.end())
        closing=next((b for a,b in pairs if a==opening),None); rel=str(path.relative_to(ROOT))
        if closing is None: skipped.append(f"{rel}: unmatched fetchFromGitHub block"); continue
        body=source[opening+1:closing]
        fields={k:p.search(body) for k,p in FIELDS.items()}
        owner=fields["owner"].group(1) if fields["owner"] else None
        repo=fields["repo"].group(1) if fields["repo"] else None
        h=fields["hash"] or fields["sha256"]; rev=fields["tag"] or fields["rev"]
        expr=source[call.end():closing]
        uses_ver=bool(re.search(r"\brev[ \t]*=[ \t]*finalAttrs\.version[ \t]*;",expr))
        if not(owner and repo and h and (rev or uses_ver)): skipped.append(f"{rel}: non-literal GitHub source fields"); continue
        if SUBMODULE.search(body): skipped.append(f"{rel}: {owner}/{repo} uses submodules"); continue
        enclosing=[(a,b) for a,b in pairs if a<opening and b>closing]
        parent=""
        if enclosing:
            a,b=min(enclosing,key=lambda x:x[1]-x[0]); parent=source[a+1:b]
        ver=VERSION.search(parent)
        if uses_ver and not ver: skipped.append(f"{rel}: {owner}/{repo} has no literal version"); continue
        current=ver.group(2) if uses_ver and ver else (rev.group(1) if rev else "")
        # A quoted Nix interpolation is not a literal Git ref. Treating
        # rev = "${version}" as a ref makes the archive lookup request
        # /archive/${version}.tar.gz, which fails with a misleading 404.
        if "${" in current:
            skipped.append(f"{rel}: {owner}/{repo} uses a dynamic Nix revision ({current}); only literal refs can be checked.")
            continue
        release=gh.release(owner,repo)
        if release is None:
            commit=gh.latest_commit(owner,repo)
            if not commit or not isinstance(commit.get("sha"),str):
                skipped.append(f"{rel}: {owner}/{repo} has no release or default-branch commit.")
                continue
            latest=commit["sha"]; kind="commit"
            if current.lower()==latest.lower() or (re.fullmatch(r"[0-9a-fA-F]{7,40}",current) and latest.lower().startswith(current.lower())):
                continue
            release={"tag_name":latest,"html_url":commit.get("html_url"),
                     "body":f"Default branch {commit['branch']} latest commit ({commit.get('date','')}):\\n\\n{commit.get('message','')}"}
        else:
            if not TAG.fullmatch(current):
                skipped.append(f"{rel}: {owner}/{repo} is commit-pinned while releases exist; automatic commit updates are only used when no release is published.")
                continue
            latest=release.get("tag_name")
            if not isinstance(latest,str) or not TAG.fullmatch(latest):
                skipped.append(f"{rel}: {owner}/{repo} has a non-stable latest release tag.")
                continue
            kind="release"
            if latest==current: continue
        new_version=None; version_span=None
        if kind=="commit":
            if uses_ver:
                new_version=latest; version_span=ver.span(2)
            elif ver and (ver.group(2)==current or (current.startswith("v") and current[1:]==ver.group(2))):
                new_version=latest; version_span=ver.span(2)
        elif uses_ver:
            new_version=latest; version_span=ver.span(2)
        elif ver:
            old_version=ver.group(2)
            if old_version==current: new_version=latest
            elif current.startswith("v") and current[1:]==old_version:
                new_version=latest[1:] if latest.startswith("v") else latest
            else:
                skipped.append(f"{rel}: {owner}/{repo} has a separate version value; skipped to avoid a stale version.")
                continue
            version_span=ver.span(2)
        root=SOURCE_ROOT.search(parent)
        updates.append(dict(path=path,call=call.start(),opening=opening,closing=closing,owner=owner,repo=repo,
            current=current,latest=latest,kind=kind,hash=hash_for(owner,repo,latest,raw_ref=(kind=="commit")),
            hash_field="hash" if fields["hash"] else "sha256",rev_field="tag" if fields["tag"] else "rev",
            uses_version=uses_ver,new_version=new_version,version_span=version_span,release=release,
            source_root=root.group(1).lstrip("/") if root else ""))
    return updates,skipped

def apply(source,updates):
    for u in sorted(updates,key=lambda x:x["call"],reverse=True):
        start,end=u["opening"]+1,u["closing"]; body=source[start:end]
        if not u["uses_version"]:
            field=u["rev_field"]
            rx=re.compile(r'(?m)^([ \\t]*)'+field+r'([ \\t]*=[ \\t]*)"[^"]+";')
            def replace_revision(match):
                attr="rev" if u["kind"]=="commit" and field=="tag" else field
                return match.group(1)+attr+match.group(2)+'"'+u["latest"]+'";'
            body,n=rx.subn(replace_revision,body,count=1)
            if n!=1: continue
        rx=re.compile(r'(?m)^([ \\t]*'+u["hash_field"]+r'[ \\t]*=[ \\t]*")[^"]+(";)')
        body,n=rx.subn(lambda m:m.group(1)+u["hash"]+m.group(2),body,count=1)
        if n!=1: continue
        source=source[:start]+body+source[end:]
        if u["version_span"]:
            a,b=u["version_span"]; source=source[:a]+u["new_version"]+source[b:]
    return source

def main():
    gh=GitHub(); updates=[]; skipped=[]
    tracked = subprocess.run(["git","ls-files","-z","--","*.nix"],cwd=ROOT,check=True,capture_output=True).stdout
    files = [ROOT/Path(name.decode()) for name in tracked.split(bytes([0])) if name]
    for path in sorted(files):
        old=path.read_text(); found,notes=inspect(path,old,gh); skipped.extend(notes)
        if not found: continue
        new=apply(old,found)
        if new==old: continue
        path.write_text(new)
        for u in found:
            cfg=summarize(gh.config(u["owner"],u["repo"],u["current"],u["source_root"],raw_ref=(u["kind"]=="commit")),
                          gh.config(u["owner"],u["repo"],u["latest"],u["source_root"],raw_ref=(u["kind"]=="commit")))
            notes=(u["release"].get("body") or "").strip()
            if len(notes)>5000: notes=notes[:5000].rstrip()+"\n\n(Release notes truncated.)"
            updates.append({**u,"path":path.relative_to(ROOT),"url":u["release"].get("html_url",""),
                            "config":cfg,"notes":notes or "No release notes provided."})
    report=["## Scheduled GitHub source update report",""]
    if updates:
        report += ["### Proposed updates",""]
        for u in updates:
            label="default-branch commit" if u["kind"]=="commit" else "release"
            report += [f"#### {u['path']}: {u['owner']}/{u['repo']} {u['current']} -> {u['latest']} ({label})",
                f"Release: {u['url']}","","Config changes",*[f"- {x}" for x in u["config"]],"","Release notes","",u["notes"],""]
    else: report += ["No newer stable releases or default-branch commits found for monitored GitHub sources.",""]
    if skipped: report += ["### Skipped pins","",*[f"- {x}" for x in skipped],""]
    text="\n".join(report).rstrip()+"\n"
    if (p:=os.environ.get("GITHUB_STEP_SUMMARY")):
        with open(p,"a",encoding="utf-8") as out: out.write(text)
    if (p:=os.environ.get("NIX_SOURCE_PR_BODY")) and updates: Path(p).write_text(text,encoding="utf-8")
    print(text)
    if updates: print(f"Found {len(updates)} GitHub source update(s).")

if __name__=="__main__": main()
