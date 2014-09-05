#! /usr/bin/python

import sys
import solv

if len(sys.argv) < 3:
   print "usage: createdrops.py <oss.solv> <non-oss.solv> old.solv [more old.solv]*"
   sys.exit(1)

def drops_for_repo(drops, filename):

    pool = solv.Pool()
    pool.setarch()

    facrepo = pool.add_repo("oss")
    facrepo.add_solv(sys.argv[1])

    nonossrepo = pool.add_repo("non-oss")
    nonossrepo.add_solv(sys.argv[2])

    sysrepo = pool.add_repo(filename)
    sysrepo.add_solv(filename)

    pool.createwhatprovides()

    for s in sysrepo.solvables:
        haveit = False
        for s2 in pool.whatprovides(s.nameid):
            if s2.repo == sysrepo or s.nameid != s2.nameid:
                continue
            haveit = True
        if haveit:
            continue
        nevr = pool.rel2id(s.nameid, s.evrid, solv.REL_EQ)
        for s2 in pool.whatmatchesdep(solv.SOLVABLE_OBSOLETES, nevr):
            if s2.repo == sysrepo:
                continue
            haveit = True
        if haveit:
            continue
        if s.name not in drops:
            drops[s.name] = sysrepo.name

    # mark it explicitly to avoid having 2 pools while GC is not run
    del pool

drops = dict()

for repo in sys.argv[3:]:
    drops_for_repo(drops, repo)

for reponame in sorted(set(drops.values())):
    printedname = reponame.replace('.repo.solv', '')
    print "<!-- %s -->" % printedname
    for p in sorted(drops):
        if drops[p] != reponame: continue
        print "  <obsoletepackage>%s</obsoletepackage>" % p

