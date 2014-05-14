import sys
import collections

def calc_freq(filename):
    raw_data = open(filename, 'r').read()
    raw_data = raw_data.split('\n')
    freq = {}
    for line in raw_data:
        record = line.split(',')[1:]
        if len(record) != 3:
            continue

        # process every AP (1, 2, 3)
        for k,v in enumerate(record):
            freq.setdefault(v, [0, 0, 0])
            freq[v][k] += 1


    freq_ordered = collections.OrderedDict(sorted(freq.items()))
    output = filename.split('_')[1]
    with open(output, 'w') as fp:
        for k, v in freq_ordered.iteritems():
            fp.write('%s,%d,%d,%d\n' % (k, v[0], v[1], v[2]))
    return [output, freq_ordered]


def main():
    input_file = sys.argv[1]
    output, freq = calc_freq(input_file)



if __name__ == '__main__':
    main()
