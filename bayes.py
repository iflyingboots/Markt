#!/usr/bin/env python
import math

CELLS = 10


def prob_by_cell_device(rssi, cell, ap_dist):
    """
    Produce prob with given AP(iPad1, iPad2, iPhon1) distribution
    NB: 'ap_dist' should be the object returned by read_dist()
    """
    assert(cell > 0)
    assert(cell <= CELLS)
    # cell [1, 10]
    cell = int(cell) - 1
    return normpdf(rssi, ap_dist[cell][0], ap_dist[cell][1])


def normpdf(x, mean, sd):
    """
    Generate normal distribution pdf by given mean, sd and x
    """
    var = float(sd) ** 2
    pi = 3.1415926
    denom = (2 * pi * var) ** .5
    num = math.exp(-(float(x) - float(mean)) ** 2 / (2 * var))
    return num / denom


def dot_product(v1, v2):
    assert(len(v1) == len(v2))
    # Pythonic way
    return [i * j for i, j in zip(v1, v2)]
    # general method
    res = []
    for i in xrange(len(v1)):
        res.append(v1[i] * v2[i])
    return res


def read_dist(filename):
    """
    Return normal distribution parameters (mean, sd) from given file
    @return
    [
     (cell1_mean, cell1_sd),
     (cell2_mean, cell2_sd),
     ...
    ]
    """
    data = open(filename).read().split('\n')
    prob = []
    for record in data:
        record = record.split(',')
        prob.append((float(record[1]), float(record[2])))
    return prob


def calc_cell_prob(rssi, ap):
    """
    Calculate probs (8 cells) by given RSSI and one AP
    """
    assert(len(ap) == CELLS)
    prob = []
    cell = 1
    # 8 distribution (cell1 to cell8)
    print ap
    exit()
    for dist in ap:
        prob.append(prob_by_cell_device(rssi, cell, ap))
        cell += 1
    return prob


def calc_posterior(prior, rssi_dist):
    return dot_product(prior, rssi_dist)


def estimate_cell(RSSIs, priors):
    # prob in each cell
    probs = [calc_cell_prob(RSSIs[i], APs[i]) for i in xrange(3)]
    posteriors = []
    posteriors = [calc_posterior(priors[i], probs[i]) for i in xrange(3)]

    normalized_posteriors = []
    for post in posteriors:
        normalized_posteriors.append([i / sum(post) for i in post])

    calculated_cells = [normalized_posteriors[i]
                        .index(max(normalized_posteriors[i])) + 1 for i in xrange(3)]
    print 'RSSI: ', RSSIs
    print 'Calculated: ', calculated_cells
    print['%2.5f' % max(i) for i in normalized_posteriors]
    print
    return normalized_posteriors


def main():
    # initial belief: prior prob
    prior = [1.0 / CELLS for i in xrange(CELLS)]
    global APs
    APs = [
        read_dist('rssi_data_final/ipad1.txt'),
        read_dist('rssi_data_final/ipad2.txt'),
        read_dist('rssi_data_final/iphone1.txt')
    ]

    priors = [prior for i in xrange(3)]

    RSSI_cells = [
        [-72, -85, -71],
        [-69, -81, -76],
        [-47, -76, -78],
        [-76, 0, 0],
        [-58, -72, -86],
        [-66, -68, -89],
        [-73, -55, -93],
        [-73, -78, -90],
    ]

    cell_RSSIs = [
[-70,0,0],
[-70,0,0],
[-71,0,0],
[-71,-92,0],
[-71,-92,0],
[-73,-92,0],
[-73,-93,0],
[-73,-93,0],
[-80,-93,0],
[-80,0,0],
[-80,0,0],
[-84,0,0],
[-84,0,0],
[-84,0,0],
[-85,0,0],
[-85,0,0],
[-85,0,0],
[-85,0,0],
[-85,0,0],
[-85,0,0],
[-82,0,0],
[-82,-89,0],
[-82,-89,0],
[-72,-89,0],
[-72,-88,0],
[-72,-88,0],
[-70,-88,0],
[-70,-89,0],
[-70,-89,0],
[-73,-89,0],
[-73,-91,0],
[-73,-91,0],
[-76,-91,0],
[-76,0,0],
[-76,0,0],
[-80,0,0],
[-80,0,0],
[-80,0,0],
[-82,0,0],
[-82,0,0],
[-82,0,0],
[-83,0,0],
[-83,0,0],
[-83,0,0],
[-82,0,0],
[-82,0,0],
[-82,0,0],
[-80,0,0],
[-80,0,0],
[-80,0,0],
[-80,0,0],
[-80,-91,0],
[-80,-91,0],
[-73,-91,0],
[-73,-89,0],
[-73,-89,0],
[-71,-89,0],
[-71,-86,0],
[-71,-86,0],
[-72,-86,0],
[-72,-91,0],
[-72,-91,0],
[-75,-91,0],
[-75,0,0],
[-75,0,0],
[-78,0,0],
[-78,0,0],
[-78,0,0],
[-83,0,0],
[-83,0,0],
[-83,0,0],
[-82,0,0],
[-82,0,0],
[-82,0,0],
[-82,0,0],
[-82,0,0],
[-82,0,0],
[-81,0,0],
[-81,0,0],
[-81,0,0],
[-82,0,0],
[-82,0,0],
[-82,0,0],
[-83,0,0],
[-83,0,0],
[-83,0,0],
[-82,0,0],
[-82,0,0],
[-82,0,0],
[-80,0,0],
[-80,0,0],
[-80,0,0],
[-78,0,0],
[-78,0,0],
[-78,0,0],
[-78,0,0],
[-78,0,0],
[-78,0,0],
[-79,0,0],
[-79,0,0],
[-79,0,0],
[-79,0,0],
[-79,0,0],
[-79,0,0],
[-71,0,0],
[-71,-90,0],
[-71,-90,0],
[-70,-90,0],
[-70,-92,0],
[-70,-92,0],
[-78,-92,0],
[-78,0,0],
[-78,0,0],
[-73,0,0],
[-73,0,0],
[-73,0,0],
[-74,0,0],
[-74,0,0],
[-74,0,0],
[-74,0,0],
[-74,0,0],
[-74,0,0],
[-75,0,0],
[-75,-87,0],
[-75,-87,0],
[-77,-87,0],
[-77,-88,0],
[-77,-88,0],
[-78,-88,0],
[-78,0,0],
[-78,0,0],
[-75,0,0],
[-75,0,0],
[-75,0,0],
[-78,0,0],
[-78,0,0],
[-78,0,0],
[-84,0,0],
[-84,0,0],
[-84,0,0],
[-83,0,0],
[-83,0,0],
[-83,0,0],
[-82,0,0],
[-82,0,0],
[-82,0,0],
[-83,0,0],
[-83,0,0],
[-83,0,0],
[-83,0,0],
[-83,0,0],
[-83,0,0],
[-82,0,0],
[-82,0,0],
[-82,0,0],
[-84,0,0],
[-84,0,0],
[-84,0,0],
[-79,0,0],
[-79,0,0],
[-77,0,0],
[-77,0,0],
[-77,0,0],
[-77,0,0],
[-77,0,0],
[-77,0,0],
[-77,0,0],
[-77,-92,0],
[-77,-92,0],
[-78,-92,0],
[-78,-90,0],
[-78,-90,0],
[-78,-90,0],
[-78,-87,0],
[-78,-87,0],
[-75,-87,0],
[-75,-86,0],
[-75,-86,0],
[-69,-86,0],
[-69,-85,0],
[-69,-85,0],
[-69,-85,0],
[-69,-83,0],
[-69,-83,0],
[-68,-83,0],
[-68,-82,0],
[-68,-82,0],
[-72,-82,0],
[-72,-89,0],
[-72,-89,0],
[-76,-89,0],
[-76,-92,0],
[-76,-92,0],
[-77,-92,0],
[-77,-92,0],
[-77,-92,0],
[-79,-92,0],
[-79,0,0],
[-79,0,0],
[-79,0,0],
[-79,-88,0],
[-79,-88,0],
[-79,-88,0],
[-79,-85,0],
[-79,-85,0],
[-75,-85,0],
[-75,-86,0],
[-75,-86,0],
[-68,-86,0],
[-68,-86,0],
[-68,-86,0],
[-68,-86,0],
[-68,-85,0],
[-68,-85,0],
[-73,-85,0],
[-73,-88,0],
[-73,-88,0],
[-73,-88,0],
[-73,-90,0],
[-73,-90,0],
[-79,-90,0],
[-79,0,0],
[-79,0,0],
[-81,0,0],
[-81,0,0],
[-81,0,0],
[-79,0,0],
[-79,0,0],
[-79,0,0],
[-76,0,0],
[-76,0,0],
[-76,0,0],
[-78,0,0],
[-78,0,0],
[-78,0,0],
[-81,0,0],
[-81,0,0],
[-81,0,0],
[-82,0,0],
[-82,0,0],
[-82,0,0],
[-82,0,0],
[-82,0,0],
[-82,0,0],
[-80,0,0],
[-80,0,0],
[-80,0,0],
[-78,0,0],
[-78,0,0],
[-78,0,0],
[-79,0,0],
[-79,0,0],
[-79,0,0],
[-77,0,0],
[-77,0,0],
[-77,0,0],
[-77,0,0],
[-77,0,0],
[-77,0,0],
[-82,0,0],
[-82,0,0],
[-82,0,0],
[-84,0,0],
[-84,0,0],
[-84,0,0],
[-84,0,0],
[-84,0,0],
[-84,0,0],
[-79,0,0],
[-79,-91,0],
[-79,-91,0],
[-69,-91,0],
[-69,-88,0],
[-69,-88,0],
[-70,-88,0],
[-70,-87,0],
[-70,-87,0],
[-73,-87,0],
[-73,-88,0],
[-73,-88,0],
[-75,-88,0],
[-75,-87,0],
[-75,-87,0],
[-72,-87,0],
[-72,-86,0],
[-72,-86,0],
[-71,-86,0],
[-71,-85,0],
[-71,-85,0],
[-71,-85,0],
[-71,-87,0],
[-71,-87,0],
[-72,-87,0],
[-72,-91,0],
[-72,-91,0],
[-74,-91,0],
[-74,0,0],
[-74,0,0],
[-77,0,0],
[-77,0,0],
[-77,0,0],
[-78,0,0],
[-78,0,0],
[-78,0,0],
[-78,0,0],
[-78,0,0],
[-78,0,0],
[-77,0,0],
[-77,0,0],
[-77,0,0],
[-77,0,0],
[-77,0,0],
[-77,0,0],
[-76,0,0],
[-76,-89,0],
[-76,-89,0],
[-78,-89,0],
[-78,-86,0],
[-78,-86,0],
[-76,-86,0],
[-76,-85,0],
[-76,-85,0],
[-72,-85,0],
[-72,-85,0],
[-72,-85,0],
[-69,-85,0],
[-69,-83,0],
[-69,-83,0],
[-64,-83,0],
[-64,-86,0],
[-64,-86,0],
[-69,-86,0],
[-69,-90,0],
[-69,-90,0],
[-76,-90,0],
[-76,-89,0],
[-76,-89,0],
[-78,-89,0],
[-78,-91,0],
[-78,-91,0],
[-76,-91,0],
[-76,0,0],
[-76,0,0],
[-75,0,0],
[-75,0,0],
[-75,0,0],
[-72,0,0],
[-72,-89,0],
[-72,-89,0],
[-73,-89,0],
[-73,-87,0],
[-73,-87,0],
[-80,-87,0],
[-80,-89,0],
[-80,-89,0],
[-77,-89,0],
[-77,-88,0],
[-77,-88,0],
[-72,-88,0],
[-72,-89,0],
[-72,-89,0],
[-71,-89,0],
[-71,-91,0],
[-71,-91,0],
[-78,-91,0],
    ]

    priors_in = priors
    for i in xrange(len(cell_RSSIs)):
    # for i in xrange(2):
        print i
        priors_in = estimate_cell(cell_RSSIs[i], priors_in)

        # print 'highest RSSI: %d' % (RSSI_cells.index(max(RSSI_cells)) + 1,)
        # print 'should be :%d' % (i + 1)
        # print ''
    return

if __name__ == "__main__":
    main()