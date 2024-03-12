## HTML-2-PDF API Service

Provides a single endpoint to convert raw HTML into a PDF document with an optional page size.

The container starts up a headless Chrome browser instance and creates pages with the HTML content provided to export to a PDF file.
Even though JavaScript and service workers are disabled, you should host this in private and only use trusted HTML to avoid any security concerns.

### Usage
```
docker run -p:8080:5000 deventerprisesoftware/html2pdf
```

### Example
```
curl \
-d '{ "html": "<h1>HTML 2 PDF</h1><p>Sample text</p>", "format": "A4" }' \
-H "Content-Type: application/json" \
--output test_file.pdf \
-XPOST "http://localhost:8080/"
```
