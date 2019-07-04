const express = require('express');
const router = express.Router();

router.post('/login',(req, res) => {
  res.json({
    token: '@todo login',
  });
});

router.post('/logout', (req, res) => {
  res.send('@todo logout');
});

router.post('/book/:product', (req, res) => {
  res.send(`@todo book product ${req.params.product}`);
});

router.post('/buy/:cart', (req, res) => {
  res.send(`@todo buy products in cart ${req.params.cart}`);
});

router.post('/search', (req, res) => {
  res.send('@todo search of products');
});

router
  .route('/users')
  .post((req, res) => {
    res.send('@todo create users');
  })
  .get((req, res) => {
    res.send('@todo read users');
  })
  .put((req, res) => {
    res.send('@todo update users');
  })
  .delete((req, res) => {
    res.send('@todo delete users');
  });

router
  .route('/users/:id')
  .post((req, res) => {
    res.send(`@todo create user ${req.params.id}`)
  })
  .get((req, res) => {
    res.send(`@todo read user ${req.params.id}`)
  })
  .put((req, res) => {
    res.send(`@todo update user ${req.params.id}`)
  })
  .delete((req, res) => {
    res.send(`@todo delete user ${req.params.id}`)
  });

router
  .route('/products')
  .post((req, res) => {
    res.send('@todo create products');
  })
  .get((req, res) => {
    res.send('@todo read products');
  })
  .put((req, res) => {
    res.send('@todo update products');
  })
  .delete((req, res) => {
    res.send('@todo delete products');
  });

router
  .route('/products/:id')
  .post((req, res) => {
    res.send(`@todo create product ${req.params.id}`)
  })
  .get((req, res) => {
    res.send(`@todo read product ${req.params.id}`)
  })
  .put((req, res) => {
    res.send(`@todo update product ${req.params.id}`)
  })
  .delete((req, res) => {
    res.send(`@todo delete product ${req.params.id}`)
  });

module.exports = router;
