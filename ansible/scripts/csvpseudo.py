#!/usr/bin/env python3
"""
Pseudonymize columns in a CSV or TSV file.

Each unique value in the column that is to be pseudonymized is assigned an
ascending number, which replaces the value in the output. Equal values are
assigned the same number, also across columns.
"""
import argparse
import csv
import collections
import itertools
import sys

from typing import Any, List, DefaultDict


def counter_dict(start: int = 1, step: int = 1) -> DefaultDict[Any, int]:
    """
    :return: A defaultdict that assigns each new unseen key an ascending number.
    :param start: The first number to assign.
    :param step: The step to add to get the next number.
    """

    counter = itertools.count(start, step)
    return collections.defaultdict(lambda: next(counter))


def do_pseudonymize(
    reader: csv.reader,
    writer: csv.writer,
    columns: List[int],
    pseudonyms: DefaultDict[Any, Any],
) -> None:
    """
    Pseudonymize a CSV-like file.

    :param reader: Input reader.
    :param writer: Output writer.
    :param columns: Set of indices of columns to pseudonymize.
    :param pseudonyms: Mapping of values to pseudonyms. Should not raise KeyError if a value has no pseudonym yet.
    """

    for row in reader:
        for index in columns:
            row[index] = pseudonyms[row[index]]

        writer.writerow(row)


def main():
    """ Main script entry point. """
    # Parse arguments
    parser = argparse.ArgumentParser(description=__doc__)

    parser.add_argument(
        "--input",
        "-i",
        help="input to read, stdin if omitted.",
        default=None,
        nargs="?",
    )

    parser.add_argument(
        "columns", nargs="+", type=int, help="column indices (0-based) to pseudonymize."
    )

    args = parser.parse_args()

    # Open file and determine input format
    if args.input:
        infile = open(args.input, "r")
    else:
        infile = sys.stdin

    sample = infile.readline()
    csv_dialect = csv.Sniffer().sniff(sample)
    infile.seek(0)

    reader = csv.reader(infile, dialect=csv_dialect)

    # Do the pseudonymization
    pseudonyms = counter_dict()

    writer = csv.writer(sys.stdout, csv_dialect)

    do_pseudonymize(reader, writer, args.columns, pseudonyms)

    # Clean up
    infile.close()


if __name__ == "__main__":
    main()
