import http from 'k6/http';
import { check, sleep } from 'k6';

const BASE_URL = __ENV.BASE_URL || 'http://localhost:8080';
const TOKEN = __ENV.ACCESS_TOKEN;
const MAP_ID = __ENV.MAP_ID || '1';

export const options = {
  stages: [
    { duration: '10s', target: 10 },   
    { duration: '30s', target: 10 },   
    { duration: '10s', target: 50 },   
    { duration: '1m', target: 50 },   
    { duration: '10s', target: 0 },    
  ],
};

const headers = {
  Authorization: `Bearer ${TOKEN}`,
  'Content-Type': 'application/json',
};

export default function () {
  // 1. 추억 목록 조회 (N+1 발생 포인트)
  const listRes = http.get(
    `${BASE_URL}/api/maps/${MAP_ID}/memories`,
    { headers, tags: { name: 'GET_memory_list' } }
  );
  check(listRes, {
    '추억 목록 200': (r) => r.status === 200,
  });

  // 2. 추억 상세 조회 (목록에서 첫 번째 ID로)
  if (listRes.status === 200) {
    const memories = JSON.parse(listRes.body).data;
    if (memories.length > 0) {
      const randomIdx = Math.floor(Math.random() * memories.length);
      const memoryId = memories[randomIdx].memoryId;
      const detailRes = http.get(
        `${BASE_URL}/api/maps/${MAP_ID}/memories/${memoryId}`,
        { headers, tags: { name: 'GET_memory_detail' } }
      );
      check(detailRes, {
        '추억 상세 200': (r) => r.status === 200,
      });
    }
  }

  sleep(1);
}
