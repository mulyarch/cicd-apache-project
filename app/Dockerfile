
FROM httpd:2.4-alpine

# Copy custom content
COPY index.html /usr/local/apache2/htdocs/

# Expose port 80
EXPOSE 80

# Health check
HEALTHCHECK --interval=30s --timeout=3s \
  CMD wget --quiet --tries=1 --spider http://localhost/ || exit 1

