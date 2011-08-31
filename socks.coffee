## Require HTTP module (to start server) and Socket.IO
express = require 'express'
pdfLib  = require('node-wkhtml')
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
    res.sendfile "#{name}.pdf"
    
    outErr = (err) -> throw err if err
    fs.unlink fileName              , outErr
    fs.unlink params['header-html'] , outErr
    fs.unlink params['footer-html'] , outErr

port = process.env.PORT || 9238
app.listen port, -> console.log "Listening on #{port}"

createFiles = (params) ->
  now = new Date().getTime().toString()

  head    = "./tmp/#{now}.head.html"
  foot    = "./tmp/#{now}.footer.html"
  content = "./tmp/#{now}.content.html"

  fs.writeFileSync head    , params['data-header-html']
  fs.writeFileSync content , params['data-html']       
  fs.writeFileSync foot    , params['data-footer-html']
  
  delete params['data-header-html']
  delete params['data-html']
  delete params['data-footer-html']

  params['header-html'] = head
  params['filename']    = content
  params['footer-html'] = foot

  return params
