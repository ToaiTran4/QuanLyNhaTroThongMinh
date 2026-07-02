function extractOwnerId(event) {
  if (event.requestContext && event.requestContext.authorizer && event.requestContext.authorizer.claims) {
    const claims = event.requestContext.authorizer.claims;
    return claims['custom:owner_id'] || null;
  }
  return null;
}

function extractContractId(event) {
  if (event.requestContext && event.requestContext.authorizer && event.requestContext.authorizer.claims) {
    const claims = event.requestContext.authorizer.claims;
    return claims['custom:contract_id'] || null;
  }
  return null;
}

function extractUserRole(event) {
  if (event.requestContext && event.requestContext.authorizer && event.requestContext.authorizer.claims) {
    const claims = event.requestContext.authorizer.claims;
    return claims['cognito:groups'] ? claims['cognito:groups'][0] : null;
  }
  return null;
}

module.exports = {
  extractOwnerId,
  extractContractId,
  extractUserRole
};
