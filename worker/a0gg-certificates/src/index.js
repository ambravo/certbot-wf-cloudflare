addEventListener('fetch', event => {
  const url = new URL(event.request.url);
  if (url.pathname === '/download') {
    event.respondWith(handleDownloadRequest(event));
  } else {
    event.respondWith(handleRequest(event));
  }
});

async function handleRequest(event) {
  try {
    const data = [];
    const keys = await A0_GG_CERTS.list();
    for (const key of keys.keys) {
      const entrie = {
        name: key.name,
        downloadUrl: `/download?key=${key.name}`
      }
      data.push(entrie);
    }
    const html = generateTableHTML(data);
    const response = new Response(html, { headers: { 'content-type': 'text/html' } });
    return response;
  } catch (e) {
    return new Response('Error: ' + e.message);
  }
}

async function handleDownloadRequest(event) {
  try {
    const url = new URL(event.request.url);
    const key = url.searchParams.get('key');
    const value = await A0_GG_CERTS.get(key, 'text');
    const response = new Response(value, { headers: { 'content-disposition': `attachment; filename="${key}"` } });
    return response;
  } catch (e) {
    return new Response('Error: ' + e.message);
  }
}

function generateTableHTML(data) {
  let html = `
  <!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>*.local.a0.gg certificates</title>
    <link href="https://cdn.jsdelivr.net/npm/tailwindcss/dist/tailwind.min.css" rel="stylesheet"></link>
  </head>
  <body>
    <div class="container mx-auto py-8">
      <h1 class="text-2xl font-bold mb-4">*.local.a0.gg - Certificates</h1>
      <table class="table-auto w-1/2">
        <tbody id="file-table-body"></tbody>
      </table>
    </div>
    <script>
      // Define the file data as a JSON object
      const files = ${JSON.stringify(data)};

      // Get the table body element
      const tableBody = document.getElementById("file-table-body");

      // Loop through each file and create a table row for it
      files.forEach((file) => {
        // Create a table row element
        const row = document.createElement("tr");

        // Create a table cell for the download button
        const downloadCell = document.createElement("td");
        downloadCell.classList.add("px-4", "py-2");
        const downloadButton = document.createElement("a");
        downloadButton.href = file.downloadUrl;
        downloadButton.textContent = "Download";
        downloadButton.classList.add(
          "px-4",
          "py-2",
          "bg-blue-500",
          "text-white",
          "rounded",
          "hover:bg-blue-700"
        );
        downloadButton.setAttribute("target", "_blank");
        downloadCell.appendChild(downloadButton);

        // Create table cells for the file name and content
        const nameCell = document.createElement("td");
        nameCell.textContent = file.name;
        nameCell.classList.add("px-4", "py-2");
        const contentCell = document.createElement("td");
    
        // Add the table cells to the table row
        row.appendChild(nameCell);
        row.appendChild(downloadCell);

    
        // Add the table row to the table body
        tableBody.appendChild(row);
      });
    </script>
  </body>
  </html>
    `
  return html;
}
