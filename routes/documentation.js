const express = require('express');
const router = express.Router();

router.get('/', function(req, res, next) {
  res.send('Here should be Swagger representation');
});

module.exports = router;
