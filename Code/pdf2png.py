import os
from pdf2image import convert_from_path

"""
This program accepts a folder of PDFs (pdf_folder)
and converts the first page of each document to a PNG file.
The images are then saved to output_folder.
This program was created with ChatGPT.
"""

def pdfs_to_pngs(pdf_folder, output_folder, dpi=300):
    os.makedirs(output_folder, exist_ok=True)

    for filename in os.listdir(pdf_folder):
        if filename.lower().endswith(".pdf"):
            pdf_path = os.path.join(pdf_folder, filename)
            base_name = os.path.splitext(filename)[0]

            print(f"Converting: {filename}")

            # Convert ONLY the first page
            pages = convert_from_path(
                pdf_path,
                dpi=dpi,
                first_page=1,
                last_page=1
            )

            # Save the first page as PNG
            page = pages[0]
            png_filename = f"{base_name}_page_1.png"
            png_path = os.path.join(output_folder, png_filename)
            page.save(png_path, "PNG")

            print(f"Saved PNG for {filename}")

if __name__ == "__main__":
    pdf_folder = "enter/path/to/folder"
    output_folder = "enter/path/to/folder"
    pdfs_to_pngs(pdf_folder, output_folder)
