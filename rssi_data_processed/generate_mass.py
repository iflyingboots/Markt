import sys
import collections

def calc_freq(filename):
    raw_data = open(filename, 'r').read()
    raw_data = raw_data.split('\n')
    freq = {}
    total = 0
    for line in raw_data:
        record = line.split(',')[1:]
        total += 1
        if len(record) != 3:
            continue

        # process every AP (1, 2, 3)
        for k,v in enumerate(record):
            freq.setdefault(v, [0, 0, 0])
            freq[v][k] += 1


    total = float(total)
    freq_ordered = collections.OrderedDict(sorted(freq.items()))
    output = filename.split('_')[1].split('.')[0] + '_mass' + '.txt'
    with open(output, 'w') as fp:
        for k, v in freq_ordered.iteritems():
            fp.write('%s,%f,%f,%f\n' % (k, float(v[0])/total, float(v[1])/total, float(v[2])/total))
    return [output, freq_ordered]


def main():
    input_file = sys.argv[1]
    output, freq = calc_freq(input_file)



if __name__ == '__main__':
    main()
