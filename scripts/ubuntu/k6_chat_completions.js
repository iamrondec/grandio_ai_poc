import http from 'k6/http';
import { sleep } from 'k6';

export const options = {
  vus: 100,
  duration: '30s',
};

export default function () {
  const url = 'http://127.0.0.1:8080/v1/chat/completions';

  const payload = JSON.stringify({
    model: 'qwen',
    messages: [
      {
        role: 'user',
        content: 'Hello how much is this product?'
      }
    ],
    max_tokens: 40,
    temperature: 0.7,
  });

  const params = {
    headers: {
      'Content-Type': 'application/json',
    },
  };

  http.post(url, payload, params);
  sleep(1);
}
