# Update the default version in action.yml, commit, push, and update v1 tag
update-version VERSION:
    @echo "Updating version to {{VERSION}}..."
    @./update-version.sh {{VERSION}}

# Show current default version
show-version:
    @grep "default:" action.yml | sed "s/.*default: '\(.*\)'/\1/"

# Help message
help:
    @echo "Available recipes:"
    @echo "  update-version VERSION  - Update default version, commit, push, and update v1 tag"
    @echo "  show-version            - Show current default version"
    @echo ""
    @echo "Example:"
    @echo "  just update-version v0.2.3"