use Laravel\Passport\Passport;

public function boot(): void
{
    $this->registerPolicies();

    // Register the routes for issuing access tokens and revoking them
    if (! $this->app->routesAreCached()) {
        Passport::routes();
    }
}
