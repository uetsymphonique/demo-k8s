echo "<!DOCTYPE html>
<html lang=\"en\">
  <head>
    <meta charset=\"UTF-8\" />
    <meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\" />
    <title>${instance_name}</title>
  </head>
  <body>
    <h1 style=\"text-align: center; margin-top: 100px\">
      My IP address: $(curl https://ipinfo.io/ip)
    </h1>
  </body>
</html>" >> index.html
