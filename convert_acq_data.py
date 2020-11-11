import bioread
import numpy as np
import sys
import argparse

def acq_to_text(data_in_from, filename, data_out_to = None):
    """
    Reads in an .acq file and converts the data to a .txt file of the same format as
    Biopac's own conversion to .txt. The output file will have the same name as the input file,
    but with .txt extension instead of .acq
    :param data_in_from: full path to file where the data can be found
    :param filename: name of the .acq file to convert.
    :param data_out_to: path to write the output to. If not set, defaults to data_in_from
    """

    if data_out_to is None:
        data_out_to = data_in_from

    # read in the data with the help of the bioread package
    data = bioread.read_file(data_in_from + filename +'.acq')

    # compile output to the same format as Biopac's own .txt data output
    output = ''
    output += filename + '\n'
    output += str(data.channels[0].samples_per_second) + ' samples per second\n'
    output += str(len(data.channels)) + ' channels\n'
    for channel in data.channels:
        output += channel.name + '\n'
        output += channel.units + '\n'

    names = ''
    datapoints = ''
    data_matrix = np.zeros((data.channels[0].point_count, len(data.channels)))

    for i, channel in enumerate(data.channels):
        names += 'CH' + str(channel.order_num) + ', '
        datapoints += str(channel.data_length) + ', '
        data_matrix[:, i] = channel.data

    data_matrix.round(decimals=8)
    output += names + '\n'
    output += datapoints + '\n'

    # write out the results
    save_to = data_out_to + filename + '.txt'
    with open(save_to,'w') as f:
        f.write(output)
    with open(save_to, 'ab') as f:
        np.savetxt(f, data_matrix, delimiter=",", fmt='%2.8g')

    return('Done')


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("data_in_from", help="path to the data directory")
    parser.add_argument("filename", help="file name for the file to be converted")
    parser.add_argument("-out", "--outdatalocation", dest="data_out_to", help="where to save the converted file")
    if len(sys.argv) < 3:
        print("please make sure you have provided at least data location and filename as shown below")
        parser.print_help(sys.stderr)
        sys.exit(1)
    args = parser.parse_args()
    acq_to_text(args.data_in_from, args.filename, args.data_out_to)
    return('Done')

if __name__ == '__main__':
    main()