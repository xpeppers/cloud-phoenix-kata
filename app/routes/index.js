const express = require('express')
const router = express.Router()
const pki = require('node-forge').pki

/* GET home page. */
router.get('/', function (req, res, next) {
  res.render('index', {title: 'Express'})
})

router.get('/crash', function (req, res, next) {
  console.log(new Error('Requested crash by endpoint /crash'))
  process.exit(1)
})

router.get('/generatecert', function (req, res, next) {
  const keys = pki.rsa.generateKeyPair(2048)
  const cert = pki.createCertificate()
  cert.publicKey = keys.publicKey
  res.send({
    keys: keys,
    cert: cert
  })
})

module.exports = router
