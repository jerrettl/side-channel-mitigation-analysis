#!/usr/bin/env python3

import matplotlib.pyplot as plt
import pandas as pd
import sys


def main():
    try:
        # If a results file is specified, use this.
        results_file = sys.argv[1]
    except:
        # Otherwise, use a default file name.
        results_file = 'results.csv'

    print(f"Parsing '{results_file}'...")
    df = parse_data(results_file)
    print(df)
    print('Parsing completed.')

    # Now time to graph!
    print('Creating graphs...')

    # List the tests used.
    tests = [col for col in df.columns if col not in ['test', 'cmdline', 'params']]

    # Create a box plot.
    # Set some styling. This is how to arrange the results for each test.
    rows = 1
    columns = len(tests)
    row_width_in = 7
    col_width_in = 5

    # Set up the figure layout.
    fig, ax = plt.subplots(rows, columns, figsize=(columns * col_width_in, rows * row_width_in))
    fig.set_tight_layout(True)
    for i, test in enumerate(tests):
        try:
            df.boxplot(column=test, by='params', rot=90, layout=(1, len(tests)), ax=ax[i])
        except TypeError:
            # There will only be one axis if there is one test, so `ax` is not indexable in this case.
            df.boxplot(column=test, by='params', rot=90, layout=(1, len(tests)), ax=ax)

    # Save the figure.
    plt.savefig('results.pdf', bbox_inches='tight')
    plt.savefig('results.svg', bbox_inches='tight')

    print('Graphs created successfully. See results.pdf and results.svg.')


# Extract data from the results CSV file and produce a pandas DataFrame.
def parse_data(results_file):
    # Read data from CSV file.
    df = pd.read_csv(open(results_file, newline=''), index_col=0)

    # Set the 'cmdline' column to string types.
    df['cmdline'] = df['cmdline'].astype('string')

    # Split the boot parameters of each run into a list.
    df['cmdline_split'] = df['cmdline'].str.split()

    # Find 'trivial' boot parameters.
    # Count the frequency of each parameter.
    c = df['cmdline_split'].explode().value_counts()
    # A 'trivial' boot parameter is one that is in every run.
    trivial = c[c == len(df)].index.tolist()

    # Place the non-trivial parameters of each run into a new column. (Used for graphing.)
    df['params'] = pd.Series([list(set([param for param in cmdline if param not in trivial])) for cmdline in df['cmdline_split']], index=df.index).str.join(' ')
    # If there are no non-trivial parameters, put default text here.
    df['params'] = df['params'].replace(r'^\s*$', 'default', regex=True)
    # Remove the temporarily-used split parameter data.
    df = df.drop(columns=['cmdline_split'])

    return df


if __name__ == '__main__':
    main()
