## HTML-2-PDF API Service

Provides a single endpoint to convert raw HTML into a PDF document with an optional page size.

The container starts up a headless Chrome browser instance and creates pages with the HTML content provided to export to a PDF file.
Even though JavaScript and service workers are disabled, you should host this in private and only use trusted HTML to avoid any security concerns.

### Usage
The container exposes port 5000 so you can bind that to a port number of your choice (8080 in the example below).
```bash
docker run -p:8080:5000 deventerprisesoftware/html2pdf
```

### Examples
#### cURL
```bash
curl \
-d '{ "html": "<h1>HTML 2 PDF</h1><p>Sample text</p>", "format": "A4" }' \
-H "Content-Type: application/json" \
--output test_file.pdf \
-XPOST "http://localhost:8080/"
```
#### C#
```cs
var request = JsonSerializer.Serialize(new { Html = "<h1>HTML 2 PDF</h1><p>Sample text</p>", Format = "A4" });

using var httpClient = new HttpClient();
using var requestContent = new StringContent(request, Encoding.UTF8, "application/json");

var response = await httpClient.PostAsync("http://localhost:8080/", requestContent);
response.EnsureSuccessStatusCode();

var pdfBytes = await response.Content.ReadAsByteArrayAsync();

await File.WriteAllBytesAsync("test_file.pdf", pdfBytes);
```
