package testimpl

import (
	"context"
	"testing"

	"github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/aws-sdk-go-v2/config"
	elbv2 "github.com/aws/aws-sdk-go-v2/service/elasticloadbalancingv2"
	elbv2types "github.com/aws/aws-sdk-go-v2/service/elasticloadbalancingv2/types"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/launchbynttdata/lcaf-component-terratest/types"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

func getELBv2Client(t *testing.T) *elbv2.Client {
	t.Helper()
	cfg, err := config.LoadDefaultConfig(context.Background())
	require.NoError(t, err, "Failed to load AWS config")
	return elbv2.NewFromConfig(cfg)
}

func TestComposableComplete(t *testing.T, ctx types.TestContext) {
	client := getELBv2Client(t)

	ruleArn := terraform.Output(t, ctx.TerratestTerraformOptions(), "arn")
	ruleId := terraform.Output(t, ctx.TerratestTerraformOptions(), "id")
	targetGroupArn := terraform.Output(t, ctx.TerratestTerraformOptions(), "target_group_arn")

	// id and arn should be the same value
	assert.Equal(t, ruleArn, ruleId, "id and arn should be equal")
	assert.NotEmpty(t, ruleArn, "Rule ARN should not be empty")

	// Verify rule via AWS API
	describeResult, err := client.DescribeRules(context.Background(), &elbv2.DescribeRulesInput{
		RuleArns: []string{ruleArn},
	})
	require.NoError(t, err, "DescribeRules should succeed")
	require.Len(t, describeResult.Rules, 1, "Should find exactly one rule")

	rule := describeResult.Rules[0]

	// Verify priority
	assert.Equal(t, "100", aws.ToString(rule.Priority), "Priority should be 100")

	// Verify action
	require.Len(t, rule.Actions, 1, "Should have exactly one action")
	assert.Equal(t, elbv2types.ActionTypeEnumForward, rule.Actions[0].Type, "Action type should be forward")
	assert.Equal(t, targetGroupArn, aws.ToString(rule.Actions[0].TargetGroupArn), "Action should forward to the correct target group")

	// Verify condition
	require.Len(t, rule.Conditions, 1, "Should have exactly one condition")
	require.NotNil(t, rule.Conditions[0].PathPatternConfig, "Condition should be a path pattern")
	require.Len(t, rule.Conditions[0].PathPatternConfig.Values, 1, "Path pattern should have one value")
	assert.Equal(t, "/api/*", rule.Conditions[0].PathPatternConfig.Values[0], "Path pattern should match /api/*")

	// Functional write operation: add a tag via AWS API
	_, err = client.AddTags(context.Background(), &elbv2.AddTagsInput{
		ResourceArns: []string{ruleArn},
		Tags: []elbv2types.Tag{
			{Key: aws.String("functional-test"), Value: aws.String("passed")},
		},
	})
	require.NoError(t, err, "AddTags should succeed")

	// Verify the tag was added
	tagResult, err := client.DescribeTags(context.Background(), &elbv2.DescribeTagsInput{
		ResourceArns: []string{ruleArn},
	})
	require.NoError(t, err, "DescribeTags should succeed")
	require.Len(t, tagResult.TagDescriptions, 1, "Should have tag descriptions for the rule")

	found := false
	for _, tag := range tagResult.TagDescriptions[0].Tags {
		if aws.ToString(tag.Key) == "functional-test" {
			assert.Equal(t, "passed", aws.ToString(tag.Value), "Tag value should be 'passed'")
			found = true
			break
		}
	}
	assert.True(t, found, "functional-test tag should be present on the rule")
}

func TestComposableCompleteReadonly(t *testing.T, ctx types.TestContext) {
	client := getELBv2Client(t)

	ruleArn := terraform.Output(t, ctx.TerratestTerraformOptions(), "arn")
	ruleId := terraform.Output(t, ctx.TerratestTerraformOptions(), "id")
	targetGroupArn := terraform.Output(t, ctx.TerratestTerraformOptions(), "target_group_arn")

	// id and arn should be the same value
	assert.Equal(t, ruleArn, ruleId, "id and arn should be equal")
	assert.NotEmpty(t, ruleArn, "Rule ARN should not be empty")

	// Verify rule via AWS API (read-only)
	describeResult, err := client.DescribeRules(context.Background(), &elbv2.DescribeRulesInput{
		RuleArns: []string{ruleArn},
	})
	require.NoError(t, err, "DescribeRules should succeed")
	require.Len(t, describeResult.Rules, 1, "Should find exactly one rule")

	rule := describeResult.Rules[0]

	// Verify priority
	assert.Equal(t, "100", aws.ToString(rule.Priority), "Priority should be 100")

	// Verify action
	require.Len(t, rule.Actions, 1, "Should have exactly one action")
	assert.Equal(t, elbv2types.ActionTypeEnumForward, rule.Actions[0].Type, "Action type should be forward")
	assert.Equal(t, targetGroupArn, aws.ToString(rule.Actions[0].TargetGroupArn), "Action should forward to the correct target group")

	// Verify condition
	require.Len(t, rule.Conditions, 1, "Should have exactly one condition")
	require.NotNil(t, rule.Conditions[0].PathPatternConfig, "Condition should be a path pattern")
	require.Len(t, rule.Conditions[0].PathPatternConfig.Values, 1, "Path pattern should have one value")
	assert.Equal(t, "/api/*", rule.Conditions[0].PathPatternConfig.Values[0], "Path pattern should match /api/*")

	// Verify tags via read-only API call
	tagResult, err := client.DescribeTags(context.Background(), &elbv2.DescribeTagsInput{
		ResourceArns: []string{ruleArn},
	})
	require.NoError(t, err, "DescribeTags should succeed")
	require.Len(t, tagResult.TagDescriptions, 1, "Should have tag descriptions for the rule")

	found := false
	for _, tag := range tagResult.TagDescriptions[0].Tags {
		if aws.ToString(tag.Key) == "Environment" {
			assert.Equal(t, "test", aws.ToString(tag.Value), "Environment tag should be 'test'")
			found = true
			break
		}
	}
	assert.True(t, found, "Environment tag should be present on the rule")
}
