a = [2,3,4]
for s in a:
    print(s>0)
b = [int(s>0) for s in a]
print(b)