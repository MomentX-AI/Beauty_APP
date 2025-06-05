package models

import "time"

// StaffPerformanceAnalysis represents the staff performance analysis model
type StaffPerformanceAnalysis struct {
	StaffID                    string                     `json:"staff_id"`
	StaffName                  string                     `json:"staff_name"`
	Role                       string                     `json:"role"`
	AvatarURL                  *string                    `json:"avatar_url,omitempty"`
	TotalRevenue               float64                    `json:"total_revenue"`
	TotalAppointmentCount      int                        `json:"total_appointment_count"`
	TotalCustomerCount         int                        `json:"total_customer_count"`
	AverageServicePrice        float64                    `json:"average_service_price"`
	PeriodStart                time.Time                  `json:"period_start"`
	PeriodEnd                  time.Time                  `json:"period_end"`
	BranchPerformances         []StaffPerformanceByBranch `json:"branch_performances"`
	OverallServicePerformances []ServicePerformance       `json:"overall_service_performances"`
}

// StaffPerformanceByBranch represents staff performance data for a specific branch
type StaffPerformanceByBranch struct {
	BranchID            string               `json:"branch_id"`
	BranchName          string               `json:"branch_name"`
	Revenue             float64              `json:"revenue"`
	AppointmentCount    int                  `json:"appointment_count"`
	CustomerCount       int                  `json:"customer_count"`
	ServicePerformances []ServicePerformance `json:"service_performances"`
}

// ServicePerformance represents performance data for a specific service
type ServicePerformance struct {
	ServiceID        string  `json:"service_id"`
	ServiceName      string  `json:"service_name"`
	Category         string  `json:"category"`
	Revenue          float64 `json:"revenue"`
	AppointmentCount int     `json:"appointment_count"`
	CustomerCount    int     `json:"customer_count"`
	AveragePrice     float64 `json:"average_price"`
}

// StaffPerformance represents simplified staff performance data
type StaffPerformance struct {
	StaffID                   string    `json:"staff_id"`
	StaffName                 string    `json:"staff_name"`
	Role                      string    `json:"role"`
	AvatarURL                 *string   `json:"avatar_url,omitempty"`
	MonthlyRevenue            float64   `json:"monthly_revenue"`
	AppointmentCount          int       `json:"appointment_count"`
	CustomerCount             int       `json:"customer_count"`
	AverageServicePrice       float64   `json:"average_service_price"`
	CustomerSatisfactionScore float64   `json:"customer_satisfaction_score"`
	CompletedAppointments     int       `json:"completed_appointments"`
	CancelledAppointments     int       `json:"cancelled_appointments"`
	AttendanceRate            float64   `json:"attendance_rate"`
	PeriodStart               time.Time `json:"period_start"`
	PeriodEnd                 time.Time `json:"period_end"`
}

// BranchPerformance represents branch performance data
type BranchPerformance struct {
	BranchID              string    `json:"branch_id"`
	BranchName            string    `json:"branch_name"`
	MonthlyRevenue        float64   `json:"monthly_revenue"`
	AppointmentCount      int       `json:"appointment_count"`
	CustomerCount         int       `json:"customer_count"`
	AverageServicePrice   float64   `json:"average_service_price"`
	CustomerRetentionRate float64   `json:"customer_retention_rate"`
	StaffCount            int       `json:"staff_count"`
	OperatingDays         int       `json:"operating_days"`
	PeriodStart           time.Time `json:"period_start"`
	PeriodEnd             time.Time `json:"period_end"`
}

// BusinessAnalytics represents overall business analytics data
type BusinessAnalytics struct {
	BusinessID            string               `json:"business_id"`
	TotalRevenue          float64              `json:"total_revenue"`
	TotalAppointments     int                  `json:"total_appointments"`
	TotalCustomers        int                  `json:"total_customers"`
	ActiveStaffCount      int                  `json:"active_staff_count"`
	ActiveBranchCount     int                  `json:"active_branch_count"`
	AverageServicePrice   float64              `json:"average_service_price"`
	CustomerRetentionRate float64              `json:"customer_retention_rate"`
	MonthOverMonthGrowth  float64              `json:"month_over_month_growth"`
	PeriodStart           time.Time            `json:"period_start"`
	PeriodEnd             time.Time            `json:"period_end"`
	BranchPerformances    []BranchPerformance  `json:"branch_performances"`
	TopServices           []ServicePerformance `json:"top_services"`
	TopStaff              []StaffPerformance   `json:"top_staff"`
}

// DashboardData represents dashboard summary data
type DashboardData struct {
	TotalRevenue             float64              `json:"total_revenue"`
	TotalAppointments        int                  `json:"total_appointments"`
	TotalCustomers           int                  `json:"total_customers"`
	AverageServicePrice      float64              `json:"average_service_price"`
	CustomerSatisfactionRate float64              `json:"customer_satisfaction_rate"`
	MonthOverMonthGrowth     float64              `json:"month_over_month_growth"`
	PendingAppointments      int                  `json:"pending_appointments"`
	TodayAppointments        int                  `json:"today_appointments"`
	WeeklyRevenue            []DailyRevenue       `json:"weekly_revenue"`
	TopServices              []ServicePerformance `json:"top_services"`
	RecentCustomers          []Customer           `json:"recent_customers"`
}

// DailyRevenue represents daily revenue data for charts
type DailyRevenue struct {
	Date    time.Time `json:"date"`
	Revenue float64   `json:"revenue"`
}

// AnalyticsRequest represents request for analytics data
type AnalyticsRequest struct {
	BusinessID string     `json:"business_id" binding:"required"`
	BranchID   *string    `json:"branch_id,omitempty"`   // Optional: filter by branch
	StaffID    *string    `json:"staff_id,omitempty"`    // Optional: filter by staff
	StartDate  *time.Time `json:"start_date,omitempty"`  // Optional: start date filter
	EndDate    *time.Time `json:"end_date,omitempty"`    // Optional: end date filter
	Period     string     `json:"period,omitempty"`      // Optional: daily, weekly, monthly, yearly
	ServiceIDs []string   `json:"service_ids,omitempty"` // Optional: filter by services
}

// RevenueAnalysis represents revenue analysis data
type RevenueAnalysis struct {
	TotalRevenue   float64          `json:"total_revenue"`
	GrowthRate     float64          `json:"growth_rate"`
	ByBranch       []BranchRevenue  `json:"by_branch"`
	ByService      []ServiceRevenue `json:"by_service"`
	ByStaff        []StaffRevenue   `json:"by_staff"`
	DailyBreakdown []DailyRevenue   `json:"daily_breakdown"`
	PeriodStart    time.Time        `json:"period_start"`
	PeriodEnd      time.Time        `json:"period_end"`
}

// BranchRevenue represents revenue data by branch
type BranchRevenue struct {
	BranchID   string  `json:"branch_id"`
	BranchName string  `json:"branch_name"`
	Revenue    float64 `json:"revenue"`
	Percentage float64 `json:"percentage"`
}

// ServiceRevenue represents revenue data by service
type ServiceRevenue struct {
	ServiceID   string  `json:"service_id"`
	ServiceName string  `json:"service_name"`
	Category    string  `json:"category"`
	Revenue     float64 `json:"revenue"`
	Percentage  float64 `json:"percentage"`
	Count       int     `json:"count"`
}

// StaffRevenue represents revenue data by staff
type StaffRevenue struct {
	StaffID    string  `json:"staff_id"`
	StaffName  string  `json:"staff_name"`
	Revenue    float64 `json:"revenue"`
	Percentage float64 `json:"percentage"`
	Count      int     `json:"count"`
}
