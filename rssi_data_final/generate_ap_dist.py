import numpy


def append(array, elements):
    """
    Appends value to array
    """
    assert(len(array) == len(elements))
    for i in xrange(len(array)):
        array[i].append(int(elements[i]))
    return array

def calc_mean_sd(filename):
    """
    Calculates the mean and standard deviation for each cell
    Returns data of three APs
    """
    # cell[1-8]
    cell_name = filename.split('_')[0]
    raw_data = open(filename, 'r').read().split('\n')
    ap_sums = [[] for i in range(3)]
    for line in raw_data:
        # remove timestamp column
        record = line.split(',')[1:]
        if len(record) != 3:
            continue

        # append values to sums
        ap_sums = append(ap_sums, record)

    # mean of all APs (iPad1, iPad2, iPhon1)
    means = map(numpy.mean, ap_sums)
    # standard deviations of all APs
    sds = map(numpy.std, ap_sums)
    return (means, sds)

def open_file(partname):
    """
    Returns file handler
    """
    return open(partname + '.txt', 'w')

def write_file(fps, mean_sds):
    """
    Write means and std into files
    """
    # for each row (3 means + 3 stds per row)
    for i in xrange(len(mean_sds)):
        # for each file handler (iPad1 iPad2 iPhone1)
        for j in xrange(len(fps)):
            # cell_id, mean, sd
            fps[j].write('%d,%f,%f\n' % (i+1, mean_sds[i][0][j], mean_sds[i][1][j]))



def main():
    # all files
    filenames = ['ipad1', 'ipad2', 'iphone1']
    # all file handlers
    files = map(open_file, filenames)
    # read cell data
    data_files = ['rssi_cell%d.txt' % (i + 1,) for i in xrange(10)]
    # get means and stds data
    data = map(calc_mean_sd, data_files)
    write_file(files, data)



if __name__ == '__main__':
    main()
