#!/bin/bash

# 測試用戶註冊 API
echo "=== 測試用戶註冊功能 ==="

# 測試註冊
echo "1. 測試註冊新用戶..."
REGISTER_RESPONSE=$(curl -s -X POST http://localhost:3001/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@beautyai.com",
    "password": "123456",
    "name": "測試用戶",
    "businessName": "測試美容院"
  }')

echo "註冊回應: $REGISTER_RESPONSE"

# 解析 token
TOKEN=$(echo $REGISTER_RESPONSE | grep -o '"token":"[^"]*"' | grep -o '[^"]*"$' | sed 's/"$//')
echo "提取的 Token: $TOKEN"

if [ ! -z "$TOKEN" ]; then
  echo ""
  echo "2. 測試獲取用戶資料..."
  PROFILE_RESPONSE=$(curl -s -X GET http://localhost:3001/api/v1/auth/me \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $TOKEN")
  
  echo "用戶資料回應: $PROFILE_RESPONSE"
fi

echo ""
echo "3. 測試登入..."
LOGIN_RESPONSE=$(curl -s -X POST http://localhost:3001/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@beautyai.com",
    "password": "123456"
  }')

echo "登入回應: $LOGIN_RESPONSE"

echo ""
echo "=== 測試完成 ===" 