FROM mcr.microsoft.com/dotnet/sdk:6.0 AS build-env
LABEL stage=build-env
WORKDIR /app

# Copy and build
COPY ./src /app

# build plugins
RUN dotnet build Plugins/Authentication.Facebook -c Release
RUN dotnet build Plugins/Authentication.Google -c Release
RUN dotnet build Plugins/DiscountRules.Standard -c Release
RUN dotnet build Plugins/ExchangeRate.McExchange -c Release
RUN dotnet build Plugins/Payments.BrainTree -c Release
RUN dotnet build Plugins/Payments.CashOnDelivery -c Release
RUN dotnet build Plugins/Payments.PayPalStandard -c Release
RUN dotnet build Plugins/Shipping.ByWeight -c Release
RUN dotnet build Plugins/Shipping.FixedRateShipping -c Release
RUN dotnet build Plugins/Shipping.ShippingPoint -c Release
RUN dotnet build Plugins/Tax.CountryStateZip -c Release
RUN dotnet build Plugins/Tax.FixedRate -c Release
RUN dotnet build Plugins/Widgets.FacebookPixel -c Release
RUN dotnet build Plugins/Widgets.GoogleAnalytics -c Release
RUN dotnet build Plugins/Widgets.Slider -c Release

# Run as privileged user
USER ContainerAdministrator
# build Web
RUN dotnet publish Web/Grand.Web -c Release -o ./build/release

#Switch back to containeruser
USER ContainerUser

# Build runtime image
FROM mcr.microsoft.com/dotnet/aspnet:6.0
EXPOSE 80
ENV ASPNETCORE_URLS http://+:80
WORKDIR /app
COPY --from=build-env /app/build/release .
COPY Settings.txt App_Data/Settings.txt
ENTRYPOINT ["dotnet", "Grand.Web.dll"]
