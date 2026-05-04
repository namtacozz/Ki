import Anthropic from '@anthropic-ai/sdk';
import 'dotenv/config';
import http from 'node:http';

const port = Number.parseInt(process.env.PORT ?? '8787', 10);
const apiKey = process.env.ANTHROPIC_API_KEY ?? process.env.ANTHROPIC_AUTH_TOKEN;
const baseURL = process.env.ANTHROPIC_BASE_URL;
const model = process.env.ANTHROPIC_MODEL ?? process.env.ANTHROPIC_DEFAULT_SONNET_MODEL ?? 'claude-sonnet-4-6';
const maxRequestBytes = 512 * 1024;
const requestTimeoutMs = Number.parseInt(process.env.ANTHROPIC_TIMEOUT_MS ?? '30000', 10);

const client = new Anthropic({
  apiKey,
  baseURL,
  timeout: requestTimeoutMs
});

function sendJson(response, statusCode, body) {
  response.writeHead(statusCode, {
    'Content-Type': 'application/json; charset=utf-8',
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Methods': 'POST, OPTIONS',
    'Access-Control-Allow-Headers': 'Content-Type'
  });
  response.end(JSON.stringify(body));
}

function readJson(request) {
  return new Promise((resolve, reject) => {
    let body = '';

    request.on('data', (chunk) => {
      body += chunk;
      if (Buffer.byteLength(body, 'utf8') > maxRequestBytes) {
        reject(new Error('request_too_large'));
        request.destroy();
      }
    });

    request.on('end', () => {
      try {
        resolve(JSON.parse(body || '{}'));
      } catch {
        reject(new Error('invalid_json'));
      }
    });

    request.on('error', reject);
  });
}

function validateRequest(body) {
  if (!['reflection', 'final_report'].includes(body.type)) {
    return 'type must be reflection or final_report';
  }

  if (typeof body.prompt !== 'string' || body.prompt.trim() === '') {
    return 'prompt must be non-empty string';
  }

  if (body.context === null || typeof body.context !== 'object' || Array.isArray(body.context)) {
    return 'context must be object';
  }

  return null;
}

function buildPrompt(body) {
  return [
    'Return only valid JSON. No markdown. No prose outside JSON.',
    `Task type: ${body.type}`,
    `Prompt: ${body.prompt}`,
    `Context JSON: ${JSON.stringify(body.context)}`
  ].join('\n\n');
}

function extractText(message) {
  if (Array.isArray(message?.content)) {
    return message.content
      .filter((block) => block.type === 'text')
      .map((block) => block.text)
      .join('\n')
      .trim();
  }

  if (typeof message?.content === 'string') {
    return message.content.trim();
  }

  if (typeof message?.output_text === 'string') {
    return message.output_text.trim();
  }

  const choiceContent = message?.choices?.[0]?.message?.content;
  if (typeof choiceContent === 'string') {
    return choiceContent.trim();
  }

  return '';
}

async function handleGenerate(request, response) {
  if (!apiKey) {
    sendJson(response, 500, { ok: false, error: 'missing ANTHROPIC_API_KEY' });
    return;
  }

  let body;
  try {
    body = await readJson(request);
  } catch (error) {
    sendJson(response, 400, { ok: false, error: error.message });
    return;
  }

  const validationError = validateRequest(body);
  if (validationError) {
    sendJson(response, 400, { ok: false, error: validationError });
    return;
  }

  try {
    const message = await client.messages.create({
      model,
      max_tokens: 1200,
      temperature: 0.7,
      messages: [
        {
          role: 'user',
          content: buildPrompt(body)
        }
      ]
    });

    const text = extractText(message);

    if (!text) {
      sendJson(response, 502, { ok: false, error: 'empty_ai_response' });
      return;
    }

    sendJson(response, 200, { ok: true, text });
  } catch (error) {
    const message = error?.message ?? 'ai_request_failed';
    sendJson(response, 502, { ok: false, error: message });
  }
}

const server = http.createServer(async (request, response) => {
  if (request.method === 'OPTIONS') {
    sendJson(response, 204, {});
    return;
  }

  if (request.method === 'POST' && request.url === '/generate') {
    await handleGenerate(request, response);
    return;
  }

  sendJson(response, 404, { ok: false, error: 'not_found' });
});

server.listen(port, () => {
  console.log(`KI AI proxy listening on http://localhost:${port}`);
});
