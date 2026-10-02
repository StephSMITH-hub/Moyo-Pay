import os, subprocess
import markdown

base_dir = r"c:\Users\USER\Desktop\Moyo Pay\Moyopay Projects\01_BRAND_NARRATIVE_AND_POSITIONING_SYSTEM"
chrome_path = r"C:\Program Files\Google\Chrome\Application\chrome.exe"

files = [
    "brand_constitution_and_voice.md",
    "market_diagnosis_and_icp_matrix.md",
    "category_design_and_mechanism.md"
]

combined_md = "# MOYOPAY BRAND NARRATIVE & POSITIONING SYSTEM\n## The Complete Strategic Constitution, Market Diagnosis, ICP Avatars & Category Design Architecture\n\n---\n\n"

for f in files:
    with open(os.path.join(base_dir, f), "r", encoding="utf-8") as fp:
        content = fp.read()
    combined_md += content + "\n\n---\n\n"

target_md = os.path.join(base_dir, "MOYOPAY_BRAND_NARRATIVE_AND_POSITIONING_COMPENDIUM.md")
target_html = os.path.join(base_dir, "MOYOPAY_BRAND_NARRATIVE_AND_POSITIONING_COMPENDIUM.html")
target_pdf = os.path.join(base_dir, "MOYOPAY_BRAND_NARRATIVE_AND_POSITIONING_COMPENDIUM.pdf")

with open(target_md, "w", encoding="utf-8") as f:
    f.write(combined_md)

html_body = markdown.markdown(
    combined_md,
    extensions=['extra', 'tables', 'fenced_code', 'toc', 'sane_lists']
)

custom_css = """
@import url('https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:ital,wght@0,300;0,400;0,500;0,600;0,700;0,800;1,400;1,600&family=JetBrains+Mono:wght@400;500;600&display=swap');

@page {
    size: A4;
    margin: 20mm 15mm 20mm 15mm;
    @bottom-right {
        content: counter(page);
        font-family: 'Plus Jakarta Sans', sans-serif;
        font-size: 8pt;
        color: #888888;
    }
    @top-left {
        content: "MOYOPAY BRAND NARRATIVE & POSITIONING SYSTEM";
        font-family: 'Plus Jakarta Sans', sans-serif;
        font-size: 7.5pt;
        color: #06261A;
        font-weight: 600;
        letter-spacing: 0.5px;
    }
}

body {
    font-family: 'Plus Jakarta Sans', -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif;
    font-size: 9.5pt;
    line-height: 1.55;
    color: #1A1A1A;
    background-color: #FFFFFF;
    margin: 0;
    padding: 0;
}

h1 {
    font-size: 20pt;
    font-weight: 800;
    color: #06261A;
    margin-top: 28pt;
    margin-bottom: 12pt;
    border-bottom: 2.5px solid #06261A;
    padding-bottom: 6pt;
    page-break-after: avoid;
    letter-spacing: -0.5px;
}

h2 {
    font-size: 14pt;
    font-weight: 700;
    color: #06261A;
    margin-top: 22pt;
    margin-bottom: 8pt;
    border-bottom: 1px solid #E5E7EB;
    padding-bottom: 4pt;
    page-break-after: avoid;
}

h3 {
    font-size: 11pt;
    font-weight: 600;
    color: #111827;
    margin-top: 14pt;
    margin-bottom: 6pt;
    page-break-after: avoid;
}

h4 {
    font-size: 10pt;
    font-weight: 600;
    color: #374151;
    margin-top: 10pt;
    margin-bottom: 4pt;
}

p {
    margin-top: 0;
    margin-bottom: 8pt;
    text-align: justify;
}

blockquote {
    border-left: 3.5px solid #06261A;
    margin: 12pt 0;
    padding: 8pt 14pt;
    background-color: #F4F7F5;
    color: #1F2937;
    font-style: italic;
    border-radius: 0 4px 4px 0;
}

blockquote p {
    margin-bottom: 4pt;
}

blockquote p:last-child {
    margin-bottom: 0;
}

table {
    width: 100%;
    border-collapse: collapse;
    margin: 12pt 0;
    font-size: 8.5pt;
    page-break-inside: avoid;
}

th, td {
    border: 1px solid #D1D5DB;
    padding: 6pt 8pt;
    text-align: left;
    vertical-align: top;
}

th {
    background-color: #06261A;
    color: #FFFFFF;
    font-weight: 600;
}

tr:nth-child(even) {
    background-color: #F9FAFB;
}

code {
    font-family: 'JetBrains Mono', monospace;
    font-size: 8pt;
    background-color: #F3F4F6;
    padding: 1.5pt 3.5pt;
    border-radius: 3px;
    color: #06261A;
}

pre {
    background-color: #0B1914;
    color: #E2E8F0;
    padding: 10pt 12pt;
    border-radius: 4px;
    overflow-x: auto;
    font-family: 'JetBrains Mono', monospace;
    font-size: 8pt;
    line-height: 1.45;
    margin: 10pt 0;
    page-break-inside: avoid;
    border-left: 3px solid #00D084;
}

pre code {
    background-color: transparent;
    color: #E2E8F0;
    padding: 0;
}

ul, ol {
    margin-top: 0;
    margin-bottom: 8pt;
    padding-left: 18pt;
}

li {
    margin-bottom: 3pt;
}

hr {
    border: 0;
    height: 1px;
    background: #E5E7EB;
    margin: 18pt 0;
}
"""

full_html = f"""<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Moyopay Brand Narrative & Positioning System</title>
    <style>
{custom_css}
    </style>
</head>
<body>
{html_body}
</body>
</html>
"""

with open(target_html, "w", encoding="utf-8") as f:
    f.write(full_html)

print("Generated HTML. Rendering PDF via Google Chrome headless...")
cmd = [
    chrome_path,
    "--headless",
    "--disable-gpu",
    "--no-pdf-header-footer",
    f"--print-to-pdf={target_pdf}",
    target_html
]

res = subprocess.run(cmd, capture_output=True, text=True)
if res.returncode == 0:
    size = os.path.getsize(target_pdf)
    print(f"SUCCESS: Generated {target_pdf} (Size: {size:,} bytes)")
else:
    print(f"FAILED: {res.stderr}")
