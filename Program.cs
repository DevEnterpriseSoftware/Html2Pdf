using Microsoft.Playwright;
using System.Reflection;

// Used for basic validation of the format.
var validPrintFormats = new HashSet<string>(StringComparer.OrdinalIgnoreCase)
{
  "Letter", "Legal", "Tabloid", "Ledger",
  "A0", "A1", "A2", "A3", "A4", "A5", "A6",
};

using var playwright = await Playwright.CreateAsync();
IBrowser? browser = null;
IBrowserContext? browserContext = null;

var builder = WebApplication.CreateSlimBuilder(args);
var app = builder.Build();

app.MapGet("/", () => TypedResults.Ok(Assembly.GetExecutingAssembly().GetName().Version));

// Single end-point to convert HTML to PDF content.
app.MapPost("/", async Task<IResult> (Html2PdfRequest request) =>
{
  if (browser?.IsConnected == false)
  {
    if (browserContext is not null)
    {
      await browserContext.DisposeAsync();
      browserContext = null;
    }

    await browser.DisposeAsync();
    browser = null;
  }

  browser ??= await playwright.Chromium.LaunchAsync(new()
  {
    Args = ["--disable-dev-shm-usage", "--no-first-run", "--no-sandbox", "--disable-setuid-sandbox"],
    Headless = true,
  });

  browserContext ??= await browser.NewContextAsync(new()
  {
    ViewportSize = new() { Height = 800, Width = 600 },
    AcceptDownloads = false,
    JavaScriptEnabled = false,
    BypassCSP = true,
    ServiceWorkers = ServiceWorkerPolicy.Block,
  });

  var page = await browserContext.NewPageAsync();

  try
  {
    await page.SetContentAsync(request.Html ?? string.Empty, new() { Timeout = 30000 });

    var pdfBytes = await page.PdfAsync(new()
    {
      Format = validPrintFormats.Contains(request.Format ?? string.Empty) ? request.Format : "Letter",
      PrintBackground = true,
      Scale = 1,
      Path = null
    });

    return TypedResults.File(pdfBytes, "application/pdf", (request.FileName ?? "file") + ".pdf");
  }
  catch (Exception ex)
  {
    return TypedResults.BadRequest(ex.ToString());
  }
  finally
  {
    if (!page.IsClosed)
    {
      await page.CloseAsync();
    }
  }
});

await app.RunAsync();

sealed record Html2PdfRequest(string Html, string? FileName, string? Format = "Letter");
