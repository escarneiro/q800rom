#!/usr/bin/env python3
"""autolabels.py FILE.s [SPEC...] - inline comments for labels that still have none,
derived from the instructions after them. Prints spec lines (- LABEL: text)."""
import re, sys
path=sys.argv[1]; specs=sys.argv[2:]
done=set()
for s in specs:
    for l in open(s):
        m=re.match(r'^(?:## |- )([A-Za-z_]\w*)',l)
        if m: done.add(m.group(1))
L=open(path).read().split('\n')
labidx={}
for i,l in enumerate(L):
    m=re.match(r'^([A-Za-z_]\w*):(.*)$',l)
    if m: labidx[m.group(1)]=i
# loop targets: a db<cc>/branch back to the label from below
back=set()
for i,l in enumerate(L):
    s=l.split('|')[0].strip()
    m=re.match(r'^(db\w+|jb\w+|b\w+)\s+(?:%d\d,)?([A-Za-z_]\w*)$',s)
    if m and m.group(2) in labidx and labidx[m.group(2)]<i: back.add(m.group(2))
def ins(i):
    out=[]
    for l in L[i+1:i+12]:
        if re.match(r'^[A-Za-z_]\w*:',l): break
        s=l.split('|')[0].strip()
        if s: out.append((s, l.split('|',1)[1].strip() if '|' in l else ''))
    return out
TRAP=re.compile(r'^_(\w+)')
def describe(lab,i):
    r=ins(i)
    if not r: return None
    s,c=r[0]
    if s.startswith('.'):
        if s.startswith(('.long','.short','.byte')) and re.search(r'0x|\d',s):
            return '(data)' if not c or re.match(r'^[0-9A-F]{8}$',c) else '(%s)'%c[:50]
        if s.startswith('.ascii'): return 'string %s'%s.split(None,1)[1][:40]
        if s.startswith('.fill'): return '(unused, zeros)'
        return None
    two=[x for x,_ in r[:3]]
    loop=' (loop)' if lab in back else ''
    if s=='rts': return 'return'
    if s=='rte': return 'return from the exception'
    m=re.match(r'^moveq #(-?\d+),%d0$',s)
    if m and len(two)>1 and re.match(r'^(rts|jbra|bra|jmp)',two[1]): return 'result %s'%m.group(1)
    m=re.match(r'^move[wl] #(-?\d+),%(fp|a6)@\(\d+\)$',s)
    if m: return 'result %s'%m.group(1)
    if re.match(r'^(jbra|bra[wls]?)\s+(\w+)$',s): return 'continue at %s'%s.split()[1]
    m=TRAP.match(s)
    if m: return '_%s%s'%(m.group(1),loop)
    m=re.match(r'^(jbsr|bsr[wls]?|jsr)\s+(?:%pc@\()?(\w+)\)?$',s)
    if m: return 'call %s%s'%(m.group(2),loop)
    for x,_ in r[:4]:
        m=TRAP.match(x)
        if m: return 'set up and call _%s%s'%(m.group(1),loop)
    if s.startswith('moveml') and s.endswith('%sp@-'): return 'save registers'
    if s.startswith('moveml %sp@+') or s.startswith('moveml %fp@('):
        if any(x.startswith(('rts','unlk','rte')) for x in two): return 'restore registers, return'
        return 'restore registers'
    if s.startswith('unlk'): return 'return'
    if s.startswith('dbf') or s.startswith('db'): return 'count down%s'%loop
    if loop: return 'loop: %s'%s.split()[0].rstrip('lbw')
    m=re.match(r'^(btst|bset|bclr|bchg) #(\d+),(.*)$',s)
    if m: return {'btst':'test','bset':'set','bclr':'clear','bchg':'flip'}[m.group(1)]+' bit %s of %s'%(m.group(2),m.group(3))
    if s.startswith(('tst','cmp')): return 'test %s'%s.split(None,1)[1] if ' ' in s else 'test'
    if s.startswith('clr'): return 'clear %s'%s.split(None,1)[1]
    m=re.match(r'^moveq #0,(%d\d)$',s)
    if m: return 'clear %s'%m.group(1)
    if s.startswith('lea'): return 'address %s'%s.split(None,1)[1].split(',')[0]
    if s.startswith('move'): return 'set %s'%s.split(',')[-1]
    m=re.match(r'^(add|sub)q?[bwl]? #(\d+),(.*)$',s)
    if m: return '%s %s to %s'%('add' if m.group(1)=='add' else 'subtract',m.group(2),m.group(3))
    if s.startswith(('jmp','jsr')): return 'jump through %s'%s.split(None,1)[1]
    return 'from here: %s'%s
for lab,i in labidx.items():
    if lab in done or L[i].split(':',1)[1].strip().startswith('|'): continue
    j=i-1
    while j>0 and re.match(r'^[A-Za-z_]\w*:',L[j]): j-=1
    if L[j].startswith('|'): continue
    d=describe(lab,i)
    if d: print('- %s: %s'%(lab,d.replace(';',',')))
