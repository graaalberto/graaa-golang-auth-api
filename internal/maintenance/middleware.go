package maintenance

import (
	"fmt"
	"net/http"
	"os"
	"strings"

	"github.com/gin-gonic/gin"
	"github.com/golang-jwt/jwt/v5"
	"github.com/google/uuid"
)

type MaintenanceClaims struct {
	UserID   string   `json:"user_id"`
	AppID    string   `json:"app_id"`
	TenantID string   `json:"tenant_id"`
	Roles    []string `json:"roles,omitempty"`
	jwt.RegisteredClaims
}

func getJWTSecret() string {
	secret := os.Getenv("MAINTENANCE_API_JWT_SECRET")
	if secret == "" {
		secret = os.Getenv("JWT_SECRET")
	}
	return secret
}

func JWTMiddleware() gin.HandlerFunc {
	return func(c *gin.Context) {
		authHeader := c.GetHeader("Authorization")
		if authHeader == "" {
			c.AbortWithStatusJSON(http.StatusUnauthorized, gin.H{"error": "Authorization header required"})
			return
		}

		const bearerPrefix = "Bearer "
		if !strings.HasPrefix(authHeader, bearerPrefix) {
			c.AbortWithStatusJSON(http.StatusUnauthorized, gin.H{"error": "Authorization header must be Bearer token"})
			return
		}

		tokenString := strings.TrimPrefix(authHeader, bearerPrefix)
		if tokenString == "" {
			c.AbortWithStatusJSON(http.StatusUnauthorized, gin.H{"error": "Bearer token required"})
			return
		}

		jwtSecret := getJWTSecret()
		if jwtSecret == "" {
			c.AbortWithStatusJSON(http.StatusInternalServerError, gin.H{"error": "JWT secret is not configured"})
			return
		}

		claims := &MaintenanceClaims{}
		parser := jwt.NewParser(jwt.WithValidMethods([]string{"HS256"}))
		token, err := parser.ParseWithClaims(tokenString, claims, func(token *jwt.Token) (interface{}, error) {
			if _, ok := token.Method.(*jwt.SigningMethodHMAC); !ok {
				return nil, fmt.Errorf("unexpected signing method: %v", token.Header["alg"])
			}
			return []byte(jwtSecret), nil
		})

		if err != nil || !token.Valid {
			c.AbortWithStatusJSON(http.StatusUnauthorized, gin.H{"error": "Invalid or expired token"})
			return
		}

		if claims.UserID == "" || claims.AppID == "" || claims.TenantID == "" {
			c.AbortWithStatusJSON(http.StatusUnauthorized, gin.H{"error": "Token missing required tenant or app claims"})
			return
		}

		c.Set("user_id", claims.UserID)
		c.Set("app_id", claims.AppID)
		c.Set("tenant_id", claims.TenantID)
		c.Set("roles", claims.Roles)
		c.Next()
	}
}

func GetTenantID(c *gin.Context) (uuid.UUID, error) {
	value, exists := c.Get("tenant_id")
	if !exists {
		return uuid.Nil, fmt.Errorf("tenant_id missing from claims")
	}

	tenantIDStr, ok := value.(string)
	if !ok {
		return uuid.Nil, fmt.Errorf("invalid tenant_id format")
	}

	tenantID, err := uuid.Parse(tenantIDStr)
	if err != nil {
		return uuid.Nil, fmt.Errorf("invalid tenant_id value")
	}

	return tenantID, nil
}
