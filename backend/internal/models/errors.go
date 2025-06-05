package models

import "errors"

// User validation errors
var (
	ErrInvalidName         = errors.New("姓名長度必須在 2-50 字符之間")
	ErrInvalidBusinessName = errors.New("商家名稱長度必須在 2-100 字符之間")
	ErrPasswordTooShort    = errors.New("密碼長度至少為 6 位")
	ErrInvalidEmail        = errors.New("電子郵件格式不正確")
	ErrEmailAlreadyExists  = errors.New("此電子郵件已被註冊")
	ErrUserNotFound        = errors.New("用戶不存在")
	ErrInvalidCredentials  = errors.New("電子郵件或密碼錯誤")
	ErrUserInactive        = errors.New("用戶帳號已被停用")
	ErrInvalidToken        = errors.New("無效的令牌")
	ErrTokenExpired        = errors.New("令牌已過期")
	ErrUnauthorized        = errors.New("未授權訪問")
	ErrPermissionDenied    = errors.New("權限不足")
)
