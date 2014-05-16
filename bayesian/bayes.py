#!/usr/bin/env python
import math

CELLS = 8


def prob_by_cell_device(rssi, cell, ap_dist):
    """
    Produce prob with given AP(iPad1, iPad2, iPhon1) distribution
    NB: 'ap_dist' should be the object returned by read_dist()
    """
    assert(cell > 0)
    assert(cell <= CELLS)
    # cell [1, 8]
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
        prob.append((float(record[0]), float(record[1])))
    return prob


def calc_cell_prob(rssi, ap):
    """
    Calculate probs (8 cells) by given RSSI and one AP
    """
    assert(len(ap) == CELLS)
    prob = []
    cell = 1
    # 8 distribution (cell1 to cell8)
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
        read_dist('data/ipad1_dist.txt'),
        read_dist('data/ipad2_dist.txt'),
        read_dist('data/iphone1_dist.txt')
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
        [-71, -77, -91],
        [-71, -76, -91],
        [-71, -76, -90],
        [-73, -76, -90],
        [-73, -72, -90],
        [-73, -72, -89],
        [-73, -72, -89],
        [-73, -74, -89],
        [-73, -74, -88],
        [-75, -74, -88],
        [-75, -76, -88],
        [-75, -76, -88],
        [-74, -76, -88],
        [-74, -76, -88],
        [-74, -76, -89],
        [-76, -76, -89],
        [-76, -79, -89],
        [-76, -79, -90],
        [-75, -79, -90],
        [-75, -78, -90],
        [-75, -78, -90],
        [-73, -78, -90],
        [-73, -78, -90],
        [-73, -78, -90],
        [-74, -78, -90],
        [-74, -78, -90],
        [-74, -78, -90],
        [-74, -78, -90],
        [-74, -78, -90],
        [-74, -78, -89],
        [-73, -78, -89],
        [-73, -77, -89],
        [-73, -77, -90],
        [-72, -77, -90],
        [-72, -77, -90],
        [-72, -77, -89],
        [-73, -77, -89],
        [-73, -78, -89],
        [-73, -78, -88],
        [-73, -78, -88],
        [-73, -77, -88],
        [-73, -77, -90],
        [-73, -77, -90],
        [-73, -78, -90],
        [-73, -78, -90],
        [-72, -78, -90],
        [-72, -78, -90],
        [-72, -78, -88],
        [-74, -78, -88],
        [-74, -77, -88],
        [-74, -77, -89],
        [-74, -77, -89],
        [-74, -77, -89],
        [-74, -77, -90],
        [-74, -77, -90],
        [-74, -77, -90],
        [-74, -77, 0],
        [-75, -77, 0],
        [-75, -76, 0],
        [-75, -76, 0],
        [-75, -76, 0],
        [-75, -74, 0],
        [-75, -74, -89],
        [-71, -74, -89],
        [-71, -74, -89],
        [-71, -74, -91],
        [-71, -74, -91],
        [-71, -74, -91],
        [-71, -74, -90],
        [-73, -74, -90],
        [-73, -76, -90],
        [-73, -76, -89],
        [-74, -76, -89],
        [-74, -74, -89],
        [-74, -74, -89],
        [-73, -74, -89],
        [-73, -74, -89],
        [-73, -74, -89],
        [-74, -74, -89],
        [-74, -76, -89],
        [-74, -76, -87],
        [-75, -76, -87],
        [-75, -78, -87],
        [-75, -78, -88],
        [-73, -78, -88],
        [-73, -79, -88],
        [-73, -79, -88],
        [-73, -79, -88],
        [-73, -78, -88],
        [-73, -78, -89],
        [-74, -78, -89],
        [-74, -78, -89],
        [-74, -78, -90],
        [-73, -78, -90],
        [-73, -77, -90],
        [-73, -77, -86],
        [-74, -77, -86],
        [-74, -77, -86],
        [-74, -77, -86],
        [-74, -77, -86],
        [-74, -77, -86],
        [-74, -77, -88],
        [-72, -77, -88],
        [-72, -76, -88],
        [-72, -76, -87],
        [-68, -76, -87],
        [-68, -76, -87],
        [-68, -76, -87],
        [-67, -76, -87],
        [-67, -76, -87],
        [-67, -76, -88],
        [-68, -76, -88],
        [-68, -77, -88],
        [-68, -77, -88],
        [-71, -77, -88],
        [-71, -76, -88],
        [-71, -76, -89],
        [-73, -76, -89],
        [-73, -76, -89],
        [-73, -76, -90],
        [-72, -76, -90],
        [-72, -75, -90],
        [-72, -75, -90],
        [-73, -75, -90],
        [-73, -74, -90],
        [-73, -74, -90],
        [-73, -74, -90],
        [-73, -75, -90],
        [-73, -75, -90],
        [-74, -75, -90],
        [-74, -76, -90],
        [-74, -76, -89],
        [-73, -76, -89],
        [-73, -77, -89],
        [-73, -77, -88],
        [-74, -77, -88],
        [-74, -78, -88],
        [-74, -78, -87],
        [-73, -78, -87],
        [-73, -77, -87],
        [-73, -77, -86],
        [-71, -77, -86],
        [-71, -77, -86],
        [-71, -77, -87],
        [-72, -77, -87],
        [-72, -76, -87],
        [-72, -76, -90],
        [-72, -76, -90],
        [-72, -77, -90],
        [-72, -77, -90],
        [-69, -77, -90],
        [-69, -75, -90],
        [-69, -75, -89],
        [-69, -75, -89],
        [-69, -76, -89],
        [-69, -76, -89],
        [-71, -76, -89],
        [-71, -76, -89],
        [-71, -76, -89],
        [-72, -76, -89],
        [-72, -77, -89],
        [-72, -77, 0],
        [-72, -77, 0],
        [-72, -76, 0],
        [-72, -76, -87],
        [-73, -76, -87],
        [-73, -76, -87],
        [-73, -76, -86],
        [-74, -76, -86],
        [-74, -78, -86],
        [-74, -78, -89],
        [-75, -78, -89],
        [-75, -76, -89],
        [-75, -76, -90],
        [-75, -76, -90],
        [-75, -77, -90],
        [-75, -77, -89],
        [-74, -77, -89],
        [-74, -78, -89],
        [-74, -78, -89],
        [-72, -78, -89]
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

    i = 0

    while i < 5:
        priors = estimate_cell(RSSIs_cell2, priors)
        i += 1


if __name__ == "__main__":
    main()
