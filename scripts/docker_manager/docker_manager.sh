#!/bin/bash

# Docker Resource Manager Script
# Usage: ./docker_manager.sh

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m' # No Color

# Function to check if Docker is running
check_docker() {
    if ! docker info >/dev/null 2>&1; then
        echo -e "${RED}❌ Docker is not running or not accessible${NC}"
        echo -e "${YELLOW}Please start Docker and try again${NC}"
        exit 1
    fi
}

# Function to show header
show_header() {
    echo -e "${BLUE}╔═══════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║          Docker Manager               ║${NC}"
    echo -e "${BLUE}╚═══════════════════════════════════════╝${NC}"
    echo
}

# Function to show main menu
show_menu() {
    echo -e "${CYAN}🐳 What would you like to do?${NC}"
    echo
    echo -e "${GREEN}📋 LIST OPTIONS:${NC}"
    echo "  1) List all containers (running + stopped)"
    echo "  2) List all images"
    echo "  3) List all volumes"
    echo "  4) List all networks"
    echo "  5) Show Docker system overview"
    echo
    echo -e "${YELLOW}🧹 CLEANUP OPTIONS:${NC}"
    echo "  6) Remove stopped containers"
    echo "  7) Remove unused images"
    echo "  8) Remove unused volumes"
    echo "  9) Remove unused networks"
    echo "  10) Clean everything (system prune)"
    echo
    echo -e "${RED}💥 DANGER ZONE:${NC}"
    echo "  11) Remove ALL containers (running + stopped)"
    echo "  12) Remove ALL images"
    echo "  13) Remove ALL volumes"
    echo "  14) Nuclear cleanup (remove everything)"
    echo
    echo -e "${BLUE}ℹ️  INFO:${NC}"
    echo "  15) Show disk usage"
    echo "  16) Show Docker info"
    echo
    echo "  0) Exit"
    echo
}

# Function to list containers
list_containers() {
    echo -e "${GREEN}📦 Docker Containers:${NC}"
    echo
    local containers=$(docker ps -a --format "table {{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}" 2>/dev/null)
    
    if [[ -z "$containers" || "$containers" == "NAMES	IMAGE	STATUS	PORTS" ]]; then
        echo -e "${YELLOW}No containers found${NC}"
    else
        echo "$containers"
    fi
    echo
}

# Function to list images
list_images() {
    echo -e "${GREEN}🖼️  Docker Images:${NC}"
    echo
    local images=$(docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.ID}}\t{{.Size}}" 2>/dev/null)
    
    if [[ -z "$images" || "$images" == "REPOSITORY	TAG	IMAGE ID	SIZE" ]]; then
        echo -e "${YELLOW}No images found${NC}"
    else
        echo "$images"
    fi
    echo
}

# Function to list volumes
list_volumes() {
    echo -e "${GREEN}💾 Docker Volumes:${NC}"
    echo
    local volumes=$(docker volume ls --format "table {{.Driver}}\t{{.Name}}" 2>/dev/null)
    
    if [[ -z "$volumes" || "$volumes" == "DRIVER	VOLUME NAME" ]]; then
        echo -e "${YELLOW}No volumes found${NC}"
    else
        echo "$volumes"
    fi
    echo
}

# Function to list networks
list_networks() {
    echo -e "${GREEN}🌐 Docker Networks:${NC}"
    echo
    local networks=$(docker network ls --format "table {{.Name}}\t{{.Driver}}\t{{.Scope}}" 2>/dev/null)
    
    if [[ -z "$networks" || "$networks" == "NAME	DRIVER	SCOPE" ]]; then
        echo -e "${YELLOW}No networks found${NC}"
    else
        echo "$networks"
    fi
    echo
}

# Function to show system overview
show_system_overview() {
    echo -e "${GREEN}🔍 Docker System Overview:${NC}"
    echo
    docker system df
    echo
}

# Function to show disk usage
show_disk_usage() {
    echo -e "${GREEN}💽 Docker Disk Usage:${NC}"
    echo
    docker system df -v
    echo
}

# Function to show Docker info
show_docker_info() {
    echo -e "${GREEN}ℹ️  Docker System Info:${NC}"
    echo
    docker info
    echo
}

# Function to confirm dangerous operations
confirm_action() {
    local action="$1"
    echo -e "${RED}⚠️  WARNING: This will $action${NC}"
    read -p "Are you sure? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${YELLOW}Operation cancelled${NC}"
        return 1
    fi
    return 0
}

# Function to remove stopped containers
remove_stopped_containers() {
    echo -e "${YELLOW}🧹 Removing stopped containers...${NC}"
    local stopped=$(docker ps -aq -f status=exited)
    
    if [[ -z "$stopped" ]]; then
        echo -e "${GREEN}✅ No stopped containers to remove${NC}"
    else
        docker rm $stopped
        echo -e "${GREEN}✅ Stopped containers removed${NC}"
    fi
    echo
}

# Function to remove unused images
remove_unused_images() {
    echo -e "${YELLOW}🧹 Removing unused images...${NC}"
    docker image prune -f
    echo -e "${GREEN}✅ Unused images removed${NC}"
    echo
}

# Function to remove unused volumes
remove_unused_volumes() {
    echo -e "${YELLOW}🧹 Removing unused volumes...${NC}"
    docker volume prune -f
    echo -e "${GREEN}✅ Unused volumes removed${NC}"
    echo
}

# Function to remove unused networks
remove_unused_networks() {
    echo -e "${YELLOW}🧹 Removing unused networks...${NC}"
    docker network prune -f
    echo -e "${GREEN}✅ Unused networks removed${NC}"
    echo
}

# Function to clean everything (system prune)
clean_everything() {
    if confirm_action "remove all unused containers, networks, images (both dangling and unreferenced), and optionally volumes"; then
        echo -e "${YELLOW}🧹 Performing system cleanup...${NC}"
        docker system prune -af --volumes
        echo -e "${GREEN}✅ System cleanup completed${NC}"
    fi
    echo
}

# Function to remove all containers
remove_all_containers() {
    if confirm_action "STOP and REMOVE ALL containers (including running ones)"; then
        echo -e "${RED}💥 Stopping all running containers...${NC}"
        local running=$(docker ps -q)
        if [[ -n "$running" ]]; then
            docker stop $running
        fi
        
        echo -e "${RED}💥 Removing all containers...${NC}"
        local all_containers=$(docker ps -aq)
        if [[ -n "$all_containers" ]]; then
            docker rm $all_containers
        fi
        echo -e "${GREEN}✅ All containers removed${NC}"
    fi
    echo
}

# Function to remove all images
remove_all_images() {
    if confirm_action "REMOVE ALL Docker images"; then
        echo -e "${RED}💥 Removing all images...${NC}"
        local all_images=$(docker images -aq)
        if [[ -n "$all_images" ]]; then
            docker rmi -f $all_images
        fi
        echo -e "${GREEN}✅ All images removed${NC}"
    fi
    echo
}

# Function to remove all volumes
remove_all_volumes() {
    if confirm_action "REMOVE ALL Docker volumes (data will be lost!)"; then
        echo -e "${RED}💥 Removing all volumes...${NC}"
        local all_volumes=$(docker volume ls -q)
        if [[ -n "$all_volumes" ]]; then
            docker volume rm $all_volumes
        fi
        echo -e "${GREEN}✅ All volumes removed${NC}"
    fi
    echo
}

# Function for nuclear cleanup
nuclear_cleanup() {
    if confirm_action "REMOVE EVERYTHING (containers, images, volumes, networks)"; then
        echo -e "${RED}💥 NUCLEAR CLEANUP: Removing everything...${NC}"
        
        # Stop all containers
        local running=$(docker ps -q)
        if [[ -n "$running" ]]; then
            echo "Stopping all containers..."
            docker stop $running
        fi
        
        # Remove all containers
        local all_containers=$(docker ps -aq)
        if [[ -n "$all_containers" ]]; then
            echo "Removing all containers..."
            docker rm $all_containers
        fi
        
        # Remove all images
        local all_images=$(docker images -aq)
        if [[ -n "$all_images" ]]; then
            echo "Removing all images..."
            docker rmi -f $all_images
        fi
        
        # Remove all volumes
        local all_volumes=$(docker volume ls -q)
        if [[ -n "$all_volumes" ]]; then
            echo "Removing all volumes..."
            docker volume rm $all_volumes
        fi
        
        # Clean system
        echo "Final system cleanup..."
        docker system prune -af
        
        echo -e "${GREEN}✅ Nuclear cleanup completed - Docker is now clean${NC}"
    fi
    echo
}

# Function to pause and wait for user input
pause() {
    echo -e "${BLUE}Press any key to continue...${NC}"
    read -n 1 -s
    echo
}

# Main function
main() {
    # Check if Docker is running
    check_docker
    
    while true; do
        clear
        show_header
        show_menu
        
        read -p "Enter your choice (0-16): " choice
        echo
        
        case $choice in
            1)
                list_containers
                pause
                ;;
            2)
                list_images
                pause
                ;;
            3)
                list_volumes
                pause
                ;;
            4)
                list_networks
                pause
                ;;
            5)
                show_system_overview
                pause
                ;;
            6)
                remove_stopped_containers
                pause
                ;;
            7)
                remove_unused_images
                pause
                ;;
            8)
                remove_unused_volumes
                pause
                ;;
            9)
                remove_unused_networks
                pause
                ;;
            10)
                clean_everything
                pause
                ;;
            11)
                remove_all_containers
                pause
                ;;
            12)
                remove_all_images
                pause
                ;;
            13)
                remove_all_volumes
                pause
                ;;
            14)
                nuclear_cleanup
                pause
                ;;
            15)
                show_disk_usage
                pause
                ;;
            16)
                show_docker_info
                pause
                ;;
            0)
                echo -e "${GREEN}👋 Bye Bye!${NC}"
                exit 0
                ;;
            *)
                echo -e "${RED}❌ Invalid choice. Please try again.${NC}"
                pause
                ;;
        esac
    done
}

# Run main function
main "$@"
