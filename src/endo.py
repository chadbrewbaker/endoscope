
def transmult(a,b):
    #List of elts?
    c = []
    for i in 0 .. len(a):
        c.append( a[b[i]])
    return c

def dictmult(a,b, elts):
    c = {}
    for e in elts:
        c[e] = a[b[e]]
    return c

def multTable(elts,mult):
    tab = []
    for a in elts:
        row = []
        for b in elts:
            row.append(mult(a,b))
        tab.append(row)
