const express = require('express');
const app = express();
const port = 3000;
const hostname = 'raspinet';
 
//testmsg = 'Network Analyzer: Powered by Raspberry Pi 4B!';
 
app.get('/', (req, res) => {
  res.sendFile(__dirname + '/public/lastscan.html'); // point to index.html and render
})
 
app.listen(port, () => {
  console.log(`Server running at:  http://${hostname}:${port}`);
  console.log('Current Directory: '+ __dirname);
  console.log('Path to index.html: '+ __dirname + '/public/index.html');
  console.log('Path to lastscan.html: '+ __dirname + '/public/lastscan.html');
})
 
