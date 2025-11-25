import re
import matplotlib.pyplot as plt

fname = "thr_part1_1.txt"

fids = []
thrs = []

with open(fname, "r") as f:
    for line in f:
        m = re.search(r"fid\s+(\d+)\s*:\s*([0-9.]+)", line)
        if m:
            fids.append(m.group(1))
            thrs.append(float(m.group(2)))

plt.figure()
plt.bar(fids, thrs)
plt.xlabel("Flow ID (fid)")
plt.ylabel("Throughput moyen (Mbps)")
plt.title("Partie 1.1 - Throughput par flux TCP")
plt.tight_layout()

plt.savefig("part1_1_throughput_bar.png")
plt.show()
