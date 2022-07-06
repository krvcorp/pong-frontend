from rest_framework import permissions
from rest_framework.exceptions import PermissionDenied

SAFE_METHODS = ["GET", "HEAD", "OPTIONS"]


class IsOwnerOrReadOnly(permissions.BasePermission):
    def has_object_permission(self, request, view, obj):
        print(request.user)
        if request.method in permissions.SAFE_METHODS:
            return True
        return obj.user == request.user


class IsNotInTimeout(permissions.BasePermission):
    def has_permission(self, request, view):
        if request.method in SAFE_METHODS:
            return True
        if request.user.is_authenticated:
            if request.user.in_timeout:
                raise PermissionDenied("You are in timeout")
            else:
                return True
        return False


class IsAdmin(permissions.BasePermission):
    def has_permission(self, request, view):
        print("checking permission")
        print(request.user)
        if request.user.is_authenticated:
            print("user is authenticated")
            if request.user.is_staff:
                return True
            else:
                raise PermissionDenied("You are not admin")
        return False
