const Joi = require('joi');

// Common validators
const uuidSchema = Joi.string().guid({ version: ['uuidv4'] });
const emailSchema = Joi.string().email().required();
const phoneSchema = Joi.string().pattern(/^[0-9+ -]{8,20}$/).required();

// Room validators
const createRoomSchema = Joi.object({
  name: Joi.string().min(1).max(100).required(),
  area_m2: Joi.number().precision(2).min(0).allow(null),
  base_rent: Joi.number().precision(2).min(0).required(),
  description: Joi.string().allow(null, ''),
  initial_electric_reading: Joi.number().precision(2).min(0).allow(null),
  initial_water_reading: Joi.number().precision(2).min(0).allow(null)
});

// Tenant profile validators
const createTenantProfileSchema = Joi.object({
  full_name: Joi.string().min(1).max(255).required(),
  national_id: Joi.string().min(1).max(20).required(),
  phone: phoneSchema,
  email: emailSchema
});

// Contract validators
const createContractSchema = Joi.object({
  room_id: uuidSchema.required(),
  tenant_profile_id: uuidSchema.required(),
  start_date: Joi.date().required(),
  end_date: Joi.date().greater(Joi.ref('start_date')).allow(null),
  deposit_amount: Joi.number().precision(2).min(0).required(),
  deposit_months: Joi.number().integer().min(1).default(1),
  monthly_rent: Joi.number().precision(2).min(0).required(),
  first_month_billing_option: Joi.string().valid('pro_rata', 'free_remainder').required(),
  min_lease_days: Joi.number().integer().min(0).allow(null)
});

module.exports = {
  uuidSchema,
  emailSchema,
  phoneSchema,
  createRoomSchema,
  createTenantProfileSchema,
  createContractSchema
};
