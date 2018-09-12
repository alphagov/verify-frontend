# 4. verify-front-journey-hint cookie

Date: 11/09/2018

## Status

Accepted

## Context

The encrypted `verify-front-journey-hint` cookie was originally created to enable the non-repudiation journey. 
When user selected an IDP, the entity_id was stored in the cookie and if the RP then sent a new Authn request 
with a parameter `journey_hint=submission_confirmation` the `/confirm-your-identity` page was rendered with the 
IDP from the cookie. The cookie was a simple JSON object:
```
{ 
    entity_id: "https://idp-entity-id.com" 
}
```

In the early 2018 we introduced a sign-in hint to help users remind what IDP they used previously. The cookie has 
been repurposed and new properties were added to it to track the IDP for each status the user encountered.
The expiry date was also extended to 18 months. For example:
```
{ 
    entity_id: "https://idp-entity-id.com",
    ATTEMPT: "https://idp-entity-id.com",
    SUCCESS: "https://idp-entity-id.com",
    FAILED: "https://idp-entity-id-1.com",
                ... 
}
```
If the user has any value in SUCCESS we show the user the sign-in hint for that IDP.

## Decision
While implementing a new Pause & Resume functionality, we came across a requirement when we needed to store the status,
the selected IDP and also the RP user has paused with. Rather than creating a new cookie it was decided to re-factor the current 
journey-hint cookie to support this. In order to know what the latest state was, a new `STATE` object was introduced in the schema.
The `STATE` gets updated with every new Authn response from an IDP. The `ATTEMPT` and `SUCCESS` was kept to keep the cookie backwards
compatible and to help with identifying if there ever was a successful verification. The `entity_id` property got removed and the
non-repudiation journey now uses the `ATTEMPT` value. The cookie schema now looks like this:
```
{   
    ATTEMPT: "https://idp-entity-id.com",
    SUCCESS: "https://idp-entity-id.com",
    STATE:  {  
                IDP: "https://idp-entity-id.com",
                RP: "https://rp-entity-id.com",
                STATUS: <SUCCESS | FAILED | FAILED_UPLIFT | CANCEL | PENDING> 
            } 
}
```

## Consequences
In addition to the attempted and succeeded IDP, we now keep only the most latest state the user has been in. The eIDAS path doesn't 
write to or read from the cookie as it's completely excluded from the eIDAS journey. 