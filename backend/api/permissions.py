from rest_framework import permissions
from rest_framework.exceptions import PermissionDenied

SAFE_METHODS = ["GET", "HEAD", "OPTIONS"]


class IsOwnerOrReadOnly(permissions.BasePermission):
    def has_object_permission(self, request, view, obj):
        if request.method in permissions.SAFE_METHODS:
            return True
        return obj.user == request.user


class IsInTimeout(permissions.BasePermission):
    def has_permission(self, request, view):
        if request.method in SAFE_METHODS:
            return True
        if request.user.is_authenticated:
            if request.user.in_timeout:
                raise PermissionDenied("You are in timeout")
            else:
                return True
        return False
