#!/usr/bin/env python3
"""comment_labels.py SPEC FILE.s - add comments to a romsrc file (comments only).

SPEC format:
  #TOP                 following lines: text appended to the file's leading comment
  ## LABEL             following lines: block comment placed above LABEL
  - LABEL: text        inline comment on LABEL's line
Lines of text are written as "| text". Blank text lines become "|".
"""
import re, sys
spec, path = sys.argv[1], sys.argv[2]
top, blocks, inline, cur = [], {}, {}, None
for l in open(spec).read().split('\n'):
    if l.startswith('#TOP'):
        cur = top
    elif l.startswith('## '):
        cur = blocks.setdefault(l[3:].strip(), [])
    elif re.match(r'^- [A-Za-z_]\w*:', l):
        lab, txt = l[2:].split(':', 1)
        inline[lab.strip()] = txt.strip()
        cur = None
    elif cur is not None:
        cur.append(l.rstrip())
for d in list(blocks.values()) + [top]:
    while d and not d[-1].strip():
        d.pop()
bad = [t for t in list(inline.values()) if ';' in t]
if bad:
    sys.exit('";" in inline comment: %s' % bad[:3])
cm = lambda t: '| ' + t if t.strip() else '|'
L = open(path).read().split('\n')
out, seen = [], set()
i = 0
while i < len(L) and L[i].startswith('|'):     # leading comment
    out.append(L[i]); i += 1
if top:
    out.append('|')
    out.extend(cm(t) for t in top)
for l in L[i:]:
    m = re.match(r'^([A-Za-z_]\w*):(\s*)(\|.*)?$', l)
    if m and (m.group(1) in blocks or m.group(1) in inline):
        lab = m.group(1); seen.add(lab)
        if lab in blocks:
            while out and out[-1] == '':
                out.pop()
            out.append('')
            out.extend(cm(t) for t in blocks[lab])
        if lab in inline and not m.group(3):
            l = '%s:%s| %s' % (lab, ' ' * max(2, 23 - len(lab)), inline[lab])
    out.append(l)
missing = (set(blocks) | set(inline)) - seen
if missing:
    sys.exit('labels not found: %s' % sorted(missing)[:10])
open(path, 'w').write('\n'.join(out))
labs = re.findall(r'^([A-Za-z_]\w*):', '\n'.join(L), re.M)
left = [x for x in labs if x not in blocks and x not in inline]
print('%s: %d labels, %d blocks, %d inline, uncommented: %s' % (path, len(labs), len(blocks), len(inline), ' '.join(left)))
