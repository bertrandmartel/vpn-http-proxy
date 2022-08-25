"use strict";

const express = require('express');
const bodyParser = require('body-parser');
const axios = require('axios');
const app = express();

app.use(bodyParser.json());

app.post('/', async (req, res) => {
    if (!req.body.url){
      return res.status(400).json({ message: "url not found" });
    }
    if (!req.body.method){
      return res.status(400).json({ message: "method not found" });
    }
    var input = {
      method: req.body.method,
      url: req.body.url,
      data: req.body.data || null,
      headers: req.body.headers || {}
    };
    if (req.body.responseType){
      input.responseType = req.body.responseType;
    }
    const result = await wrapAxios(axios(input));
    if (result.headers){
      if (result.request.res.responseUrl){
        result.headers.responseUrl = result.request.res.responseUrl;
      }
      res.set(result.headers);
    }
    if (result.status){
      res.status(result.status).send(result.data);
    } else {
      res.sendStatus(500);
    }
})

app.listen(8080, () => {
  console.log("proxy server started http://localhost:8080")
})

async function wrapAxios(promise) {
  return new Promise(function (resolve, reject) {
    promise
      .then(function (response) {
        resolve(response);
      })
      .catch(function (error) {
        if (error.response) {
          resolve(error.response);
        } else {
          console.log(error);
          resolve(error);
        }
      });
  });
}