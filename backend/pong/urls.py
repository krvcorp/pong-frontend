from django.contrib import admin
from django.urls import path, include, re_path
from django.conf import settings
from django.conf.urls.static import static
from rest_framework import permissions
from rest_framework.documentation import include_docs_urls
from rest_framework.schemas import get_schema_view
from api.permissions import IsAdmin

# from drf_yasg.views import get_schema_view
# from drf_yasg import openapi

# schema_view = get_schema_view(
#     openapi.Info(title="Pong API", default_version="v1"),
#     public=False,
#     permission_classes=[permissions.IsAdminUser],
#     authentication_classes=[],
# )

urlpatterns = [
    path("", include("base.urls")),
    path("admin/", admin.site.urls),
    path("api/", include("api.urls")),
    # Documentation
    path(
        "docs/",
        include_docs_urls(
            title="Pong API", public=False, permission_classes=[permissions.IsAdminUser]
        ),
    ),
    path(
        "schema/",
        get_schema_view(
            title="Pong API",
            description="Pong API",
            version="v1",
            permission_classes=[permissions.IsAdminUser],
        ),
        name="openapi-schema",
    ),
    # path(
    #     "swagger.json",
    #     schema_view.without_ui(cache_timeout=0),
    #     name="schema-json",
    # ),
    # path(
    #     "swagger/",
    #     schema_view.with_ui("swagger", cache_timeout=0),
    #     name="schema-swagger-ui",
    # ),
    # path("redoc/", schema_view.with_ui("redoc", cache_timeout=0), name="schema-redoc"),
]

if settings.DEBUG:
    urlpatterns += static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)
