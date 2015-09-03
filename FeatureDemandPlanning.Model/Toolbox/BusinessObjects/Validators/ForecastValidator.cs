﻿using FeatureDemandPlanning.Enumerations;
using FluentValidation;
using FluentValidation.Mvc;
using FluentValidation.Validators;
using System.Collections.Generic;
using System.Linq;

namespace FeatureDemandPlanning.BusinessObjects.Validators
{
    public class ForecastValidator : AbstractValidator<Forecast>
    {
        public const string forecastEmpty = "Please specify a forecast";
        public const string noForecastVehicle = "Please specify a forecast vehicle";
        public const string noComparisonVehicles = "Please specify at least one vehicle to compare against";
        public const string forecastSameAsComparison = "The vehicle to forecast cannot be the same as a comparison vehicle";
        public const string duplicateComparisonVehicles = "Comparison vehicle '{ComparisonVehicle}' has been specified more than once";

        public ForecastValidator(Forecast forecastToValidate)
        {
            //CascadeMode = CascadeMode.StopOnFirstFailure;

            // With fluent validation, it's actually quite hard to pass parameters to validator
            // For the duplicates, we need to compare the value with the original collection, so need reference
            // to the whole comparison vehicles collection

            InstantiateValidators(forecastToValidate);
            SetupValidationRulesForForecastVehicle();
            SetupValidationRulesForComparisonVehicles();
        }

        public static string GetRulesetsToValidate(ForecastValidationSection sectionToValidate)
        {
            var ruleSets = "*";

            switch (sectionToValidate)
            {
                case ForecastValidationSection.ForecastVehicle:
                    ruleSets = "ForecastVehicle";
                    break;
                case ForecastValidationSection.ForecastAndComparisonVehicles:
                    ruleSets = "ForecastVehicles,ComparisonVehicles";
                    break;
                case ForecastValidationSection.ComparisonVehicles:
                    ruleSets = "ComparisonVehicles";
                    break;
                case ForecastValidationSection.TrimMapping:
                    ruleSets = "TrimMapping";
                    break;
                case ForecastValidationSection.TakeRate:
                    ruleSets = "TakeRate";
                    break;
                default:
                    ruleSets = "*";
                    break;
            }
            return ruleSets;
        }

        private void SetupValidationRulesForForecastVehicle()
        {
            RuleSet("ForecastVehicle", () =>
            {

                RuleFor(f => f)
                    .NotNull()
                    .WithName("Forecast")
                    .WithMessage(forecastEmpty);

                // We must have a forecast vehicle specified i.e. not null
                // and not empty. The additional forecast vehicle validator checks the values within the forecast
                // vehicle to see if they are set
                RuleFor(f => f.ForecastVehicle)
                    .Cascade(CascadeMode.StopOnFirstFailure)
                    .NotNull()
                    //.Must(HaveAForecastVehicle)
                    //.WithMessage(noForecastVehicle)
                    .SetValidator(forecastVehicleValidator);
            });
        }

        private void SetupValidationRulesForComparisonVehicles()
        {
            RuleSet("ComparisonVehicles", () =>
            {
                // We must have at least one non-empty comparison vehicle
                RuleFor(f => f.ComparisonVehicles)
                    //.Cascade(CascadeMode.StopOnFirstFailure)
                    .NotNull()
                    .Must(HaveAtLeastOneComparisonVehicle)
                    .WithMessage(noComparisonVehicles);

                // We need to validate each comparison vehicle in turn to ensure the properties are set
                RuleFor(f => f.ComparisonVehicles)
                    //.Cascade(CascadeMode.StopOnFirstFailure)
                    .NotNull()
                    .SetCollectionValidator(comparisonValidator)
                    .Where(v => VehicleValidator.NotBeAnEmptyVehicle(v));

                // The forecast vehicle cannot be the same as one of the comparison vehicles
                RuleFor(f => f)
                    //.Cascade(CascadeMode.StopOnFirstFailure)
                    .NotNull()
                    .Must(NotHaveAForecastVehicleSameAsAComparisonVehicle)
                    .WithName("Forecast")
                    .WithMessage(forecastSameAsComparison)
                    .WithState(f => ListForecastVehiclesSameAsComparisonVehicle(f));

                // Each comparison vehicle is checked against to collection as a whole to ensure no duplicates
                RuleFor(f => f.ComparisonVehiclesToValidate)
                    //.Cascade(CascadeMode.StopOnFirstFailure)
                    .NotNull()
                    .SetCollectionValidator(duplicateValidator)
                    .Where(v => VehicleValidator.NotBeAnEmptyVehicle(v));
            });
        }

        private bool HaveAForecastVehicle(Vehicle forecastVehicle)
        {
            return forecastVehicle != null && !(forecastVehicle is EmptyVehicle);
        }

        private bool HaveAtLeastOneComparisonVehicle(IEnumerable<Vehicle> comparisonVehicles)
        {
            return comparisonVehicles.Where(v => !(v is EmptyVehicle)).Any();
        }

        private bool NotHaveAForecastVehicleSameAsAComparisonVehicle(Forecast forecast)
        {
            return !ListForecastVehiclesSameAsComparisonVehicle(forecast).Any();
        }

        private IEnumerable<VehicleWithIndex> ListForecastVehiclesSameAsComparisonVehicle(Forecast forecast)
        {
            var comparisonVehiclesSame = forecast.ComparisonVehiclesToValidate
                .Where(v => !(v.Vehicle is EmptyVehicle) && v.Vehicle.Equals(forecast.ForecastVehicle));
            return comparisonVehiclesSame;
        }

        private bool InstantiateValidators(Forecast forecast)
        {
            forecastToValidate = forecast;
            duplicateValidator = new ComparisonVehicleDuplicateValidator(forecast.ComparisonVehicles.ToVehicleWithIndexList());
            comparisonValidator = new ComparisonVehicleValidator();
            forecastVehicleValidator = new ForecastVehicleValidator();

            return true;
        }

        private ComparisonVehicleDuplicateValidator duplicateValidator = null;
        private ComparisonVehicleValidator comparisonValidator = null;
        private ForecastVehicleValidator forecastVehicleValidator = null;
        private Forecast forecastToValidate = null;

    }
}
