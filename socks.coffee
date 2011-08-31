## Require HTTP module (to start server)
express = require 'express'
pdfLib  = require './node-wkhtml'
app     = express.createServer()
fs      = require 'fs'

app.use express.bodyParser()

app.get '/', (req, res) -> res.send('this is socks')

app.post '/generate_report', (req, res) -> 
  name = req.body.name
  delete req.body.name

  params = createFiles req.body
  
  fileName = params['filename']
  delete params['filename']

  PDF = pdfLib.pdf params
  new PDF( { filename: fileName } ).convertAs "#{name}.pdf", (err, stdout) -> 
    console.log err
    res.sendfile "#{name}.pdf"
    
    outErr = (err) -> throw err if err
    if /^\.\/tmp/.test fileName
      fs.unlink fileName              , outErr
    if /^\.\/tmp/.test params['header-html']
      fs.unlink params['header-html'] , outErr
    if /^\.\/tmp/.test params['footer-html']
      fs.unlink params['footer-html'] , outErr

port = process.env.PORT || 9238
app.listen port, -> console.log "Listening on #{port}"

# Create files if needed
createFiles = (params) ->
  now = new Date().getTime().toString()
  
  params = processSection params , now , 'data-header-html' , 'header-html'
  params = processSection params , now , 'data-html'        , 'filename'
  params = processSection params , now , 'data-footer-html' , 'footer-html'

  return params

# Process each section and create files if nessary
# Otherwise don't do this step
processSection = (params, baseName, inName, outName) ->
  if params[inName]?
    tmp = "./tmp/#{baseName}.#{outName}.html"
    fs.writeFileSync tmp, params[inName]
    delete params[inName]
    params[outName] = tmp

  params
