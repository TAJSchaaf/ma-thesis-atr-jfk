import os
import csv
import requests

"""
This program accepts a csv file with a column of links to online PDF files.
It collects the links, accesses the documents, and downloads them to a new folder.
For testing purposes, it is possible to limit the number of documents being downloaded at a time.
Created with ChatGPT.

"""



CSV_FILE = "pdf_links.csv"       # path to csv file
LINK_COLUMN = "PDF_link"         # column header with links
DOWNLOAD_LIMIT = 10              # number of pdfs to download
OUTPUT_FOLDER = "downloaded_pdfs"


# create output folder

os.makedirs(OUTPUT_FOLDER, exist_ok=True)


# read csv and collect links
links = []

with open(CSV_FILE, newline='', encoding='utf-8') as f:
    reader = csv.DictReader(f)

    for row in reader:
        if LINK_COLUMN in row and row[LINK_COLUMN].strip():
            links.append(row[LINK_COLUMN].strip())

# Limit number of downloads
links = links[:DOWNLOAD_LIMIT]

print(f"Found {len(links)} links to download.")


# Download PDFs

for i, url in enumerate(links, start=1):
    try:
        filename = f"file_{i}.pdf"
        output_path = os.path.join(OUTPUT_FOLDER, filename)

        print(f"Downloading {i}/{len(links)} -> {url}")

        response = requests.get(url, timeout=30)
        response.raise_for_status()

        with open(output_path, "wb") as pdf_file:
            pdf_file.write(response.content)

    except Exception as e:
        print(f"❌ Failed to download: {url} | Error: {e}")

print("\n✔ Downloading complete!")
