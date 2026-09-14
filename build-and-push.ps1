$ErrorActionPreference = "Stop"

az acr login --name sit722acr225138095

$services = @{
    "frontend"           = "koalatech-frontend"
    "user-service"       = "koalatech-user-service"
    "student-service"    = "koalatech-student-service"
    "lecturer-service"   = "koalatech-lecturer-service"
    "course-service"     = "koalatech-course-service"
    "enrollment-service" = "koalatech-enrollment-service"
}

foreach ($dir in $services.Keys) {
    $image = "sit722acr225138095.azurecr.io/$($services[$dir]):v1"
    Write-Host "Building $image"
    docker build -t $image ./$dir
    docker push $image
}