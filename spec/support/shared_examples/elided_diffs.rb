shared_examples_for "a matcher that supports elided diffs" do
  context "when comparing two one-dimensional data structures which feature a changed section flanked by unchanged sections" do
    context "if diff_elision_enabled is set to true" do
      context "and diff_elision_padding is 0" do
        it "elides the unchanged sections" do
          as_both_colored_and_uncolored do |color_enabled|
            snippet = <<~TEST.strip
              expected = [
                "Afghanistan",
                "Aland Islands",
                "Albania",
                "Algeria",
                "American Samoa",
                "Andorra",
                "Angola",
                "Antarctica",
                "Antigua And Barbuda",
                "Argentina",
                "Armenia",
                "Aruba",
                "Australia"
              ]
              actual = [
                "Afghanistan",
                "Aland Islands",
                "Albania",
                "Algeria",
                "American Samoa",
                "Andorra",
                "Anguilla",
                "Antarctica",
                "Antigua And Barbuda",
                "Argentina",
                "Armenia",
                "Aruba",
                "Australia"
              ]
              expect(actual).to #{matcher}(expected)
            TEST
            program = make_plain_test_program(
              snippet,
              color_enabled: color_enabled,
              configuration: {
                diff_elision_enabled: true,
                diff_elision_threshold: 3,
              },
            )

            expected_output = build_expected_output(
              color_enabled: color_enabled,
              snippet: %|expect(actual).to #{matcher}(expected)|,
              newline_before_expectation: true,
              expectation: proc {
                line do
                  plain "Expected "
                  # rubocop:disable Layout/LineLength
                  beta %|["Afghanistan", "Aland Islands", "Albania", "Algeria", "American Samoa", "Andorra", "Anguilla", "Antarctica", "Antigua And Barbuda", "Argentina", "Armenia", "Aruba", "Australia"]|
                  # rubocop:enable Layout/LineLength
                end

                line do
                  plain "   to eq "
                  # rubocop:disable Layout/LineLength
                  alpha %|["Afghanistan", "Aland Islands", "Albania", "Algeria", "American Samoa", "Andorra", "Angola", "Antarctica", "Antigua And Barbuda", "Argentina", "Armenia", "Aruba", "Australia"]|
                  # rubocop:enable Layout/LineLength
                end
              },
              diff: proc {
                plain_line %|  [|
                gamma_line %|    # ...|
                plain_line %|    "Algeria",|
                plain_line %|    "American Samoa",|
                plain_line %|    "Andorra",|
                alpha_line %|-   "Angola",|
                beta_line  %|+   "Anguilla",|
                plain_line %|    "Antarctica",|
                plain_line %|    "Antigua And Barbuda",|
                plain_line %|    "Argentina",|
                gamma_line %|    # ...|
                plain_line %|  ]|
              },
            )

            expect(program).
              to produce_output_when_run(expected_output).
              in_color(color_enabled)
          end
        end
      end

      context "and diff_elision_padding is greater than 0" do
        it "elides the unchanged sections, preserving <padding> number of lines before and after the changed sections" do
          as_both_colored_and_uncolored do |color_enabled|
            snippet = <<~TEST.strip
              expected = [
                "Afghanistan",
                "Aland Islands",
                "Albania",
                "Algeria",
                "American Samoa",
                "Andorra",
                "Angola",
                "Antarctica",
                "Antigua And Barbuda",
                "Argentina",
                "Armenia",
                "Aruba",
                "Australia"
              ]
              actual = [
                "Afghanistan",
                "Aland Islands",
                "Albania",
                "Algeria",
                "American Samoa",
                "Andorra",
                "Anguilla",
                "Antarctica",
                "Antigua And Barbuda",
                "Argentina",
                "Armenia",
                "Aruba",
                "Australia"
              ]
              expect(actual).to #{matcher}(expected)
            TEST
            program = make_plain_test_program(
              snippet,
              color_enabled: color_enabled,
              configuration: {
                diff_elision_enabled: true,
                diff_elision_threshold: 2,
                diff_elision_padding: 3,
              },
            )

            expected_output = build_expected_output(
              color_enabled: color_enabled,
              snippet: %|expect(actual).to #{matcher}(expected)|,
              newline_before_expectation: true,
              expectation: proc {
                line do
                  plain "Expected "
                  # rubocop:disable Layout/LineLength
                  beta %|["Afghanistan", "Aland Islands", "Albania", "Algeria", "American Samoa", "Andorra", "Anguilla", "Antarctica", "Antigua And Barbuda", "Argentina", "Armenia", "Aruba", "Australia"]|
                  # rubocop:enable Layout/LineLength
                end

                line do
                  plain "   to eq "
                  # rubocop:disable Layout/LineLength
                  alpha %|["Afghanistan", "Aland Islands", "Albania", "Algeria", "American Samoa", "Andorra", "Angola", "Antarctica", "Antigua And Barbuda", "Argentina", "Armenia", "Aruba", "Australia"]|
                  # rubocop:enable Layout/LineLength
                end
              },
              diff: proc {
                plain_line %|  [|
                gamma_line %|    # ...|
                plain_line %|    "Algeria",|
                plain_line %|    "American Samoa",|
                plain_line %|    "Andorra",|
                alpha_line %|-   "Angola",|
                beta_line  %|+   "Anguilla",|
                plain_line %|    "Antarctica",|
                plain_line %|    "Antigua And Barbuda",|
                plain_line %|    "Argentina",|
                gamma_line %|    # ...|
                plain_line %|  ]|
              },
            )

            expect(program).
              to produce_output_when_run(expected_output).
              in_color(color_enabled)
          end
        end
      end
    end

    context "if diff_elision_enabled is set to false" do
    end
  end

  context "when comparing two one-dimensional data structures which feature a unchanged section flanked by changed sections" do
    context "if diff_elision_enabled is set to true" do
    end

    context "if diff_elision_enabled is set to false" do
    end
  end

  context "when comparing two multi-dimensional data structures which feature large unchanged sections" do
    context "if diff_elision_enabled is set to true" do
      # TODO see if we can correct the order of the keys here so it's not
      # totally weird
      it "elides the unchanged sections" do
        as_both_colored_and_uncolored do |color_enabled|
          snippet = <<~TEST.strip
            expected = [
              {
                "user_id": "18949452",
                "user": {
                  "id": 18949452,
                  "name": "Financial Times",
                  "screen_name": "FT",
                  "location": "London",
                  "entities": {
                    "url": {
                      "urls": [
                        {
                          "url": "http://t.co/dnhLQpd9BY",
                          "expanded_url": "http://www.ft.com/",
                          "display_url": "ft.com",
                          "indices": [
                            0,
                            22
                          ]
                        }
                      ]
                    },
                    "description": {
                      "urls": [
                        {
                          "url": "https://t.co/5BsmLs9y1Z",
                          "expanded_url": "http://FT.com",
                          "indices": [
                            65,
                            88
                          ]
                        }
                      ]
                    }
                  },
                  "listed_count": 37009,
                  "created_at": "Tue Jan 13 19:28:24 +0000 2009",
                  "favourites_count": 38,
                  "utc_offset": nil,
                  "time_zone": nil,
                  "geo_enabled": false,
                  "verified": true,
                  "statuses_count": 273860,
                  "media_count": 51044,
                  "contributors_enabled": false,
                  "is_translator": false,
                  "is_translation_enabled": false,
                  "profile_background_color": "FFF1E0",
                  "profile_background_image_url_https": "https://abs.twimg.com/images/themes/theme1/bg.png",
                  "profile_background_tile": false,
                  "profile_image_url": "http://pbs.twimg.com/profile_images/931156393108885504/EqEMtLhM_normal.jpg",
                  "profile_image_url_https": "https://pbs.twimg.com/profile_images/931156393108885504/EqEMtLhM_normal.jpg",
                  "profile_banner_url": "https://pbs.twimg.com/profile_banners/18949452/1581526592",
                  "profile_image_extensions": {
                    "mediaStats": {
                      "r": {
                        "missing": nil
                      },
                      "ttl": -1
                    }
                  },
                  "profile_banner_extensions": {},
                  "blocking": false,
                  "blocked_by": false,
                  "want_retweets": false,
                  "advertiser_account_type": "none",
                  "advertiser_account_service_levels": [],
                  "profile_interstitial_type": "",
                  "business_profile_state": "none",
                  "translator_type": "none",
                  "followed_by": false,
                  "ext": {
                    "highlightedLabel": {
                      "ttl": -1
                    }
                  },
                  "require_some_consent": false
                },
                "token": "117"
              }
            ]
            actual = [
              {
                "user_id": "18949452",
                "user": {
                  "id": 18949452,
                  "name": "Financial Times",
                  "screen_name": "FT",
                  "location": "London",
                  "url": "http://t.co/dnhLQpd9BY",
                  "entities": {
                    "url": {
                      "urls": [
                        {
                          "url": "http://t.co/dnhLQpd9BY",
                          "expanded_url": "http://www.ft.com/",
                          "display_url": "ft.com",
                          "indices": [
                            0,
                            22
                          ]
                        }
                      ]
                    },
                    "description": {
                      "urls": [
                        {
                          "url": "https://t.co/5BsmLs9y1Z",
                          "display_url": "FT.com",
                          "indices": [
                            65,
                            88
                          ]
                        }
                      ]
                    }
                  },
                  "protected": false,
                  "listed_count": 37009,
                  "created_at": "Tue Jan 13 19:28:24 +0000 2009",
                  "favourites_count": 38,
                  "utc_offset": nil,
                  "time_zone": nil,
                  "geo_enabled": false,
                  "verified": true,
                  "statuses_count": 273860,
                  "media_count": 51044,
                  "contributors_enabled": false,
                  "is_translator": false,
                  "is_translation_enabled": false,
                  "profile_background_color": "FFF1E0",
                  "profile_background_image_url": "http://abs.twimg.com/images/themes/theme1/bg.png",
                  "profile_image_url_https": "https://pbs.twimg.com/profile_images/931156393108885504/EqEMtLhM_normal.jpg",
                  "profile_banner_url": "https://pbs.twimg.com/profile_banners/18949452/1581526592",
                  "profile_image_extensions": {
                    "mediaStats": {
                      "r": {
                        "missing": nil
                      },
                      "ttl": -1
                    }
                  },
                  "profile_banner_extensions": {},
                  "blocking": false,
                  "blocked_by": false,
                  "want_retweets": false,
                  "advertiser_account_type": "none",
                  "profile_interstitial_type": "",
                  "business_profile_state": "none",
                  "translator_type": "none",
                  "followed_by": false,
                  "ext": {
                    "highlightedLabel": {
                      "ttl": -1
                    }
                  },
                  "require_some_consent": false
                },
                "token": "117"
              }
            ]
            expect(actual).to #{matcher}(expected)
          TEST
          program = make_plain_test_program(
            snippet,
            color_enabled: color_enabled,
            configuration: {
              diff_elision_enabled: true,
              diff_elision_threshold: 10,
            },
          )

          expected_output = build_expected_output(
            color_enabled: color_enabled,
            snippet: %|expect(actual).to #{matcher}(expected)|,
            newline_before_expectation: true,
            expectation: proc {
              line do
                plain "Expected "
                # rubocop:disable Layout/LineLength
                beta %<[{ user_id: "18949452", user: { id: 18949452, name: "Financial Times", screen_name: "FT", location: "London", url: "http://t.co/dnhLQpd9BY", entities: { url: { urls: [{ url: "http://t.co/dnhLQpd9BY", expanded_url: "http://www.ft.com/", display_url: "ft.com", indices: [0, 22] }] }, description: { urls: [{ url: "https://t.co/5BsmLs9y1Z", display_url: "FT.com", indices: [65, 88] }] } }, protected: false, listed_count: 37009, created_at: "Tue Jan 13 19:28:24 +0000 2009", favourites_count: 38, utc_offset: nil, time_zone: nil, geo_enabled: false, verified: true, statuses_count: 273860, media_count: 51044, contributors_enabled: false, is_translator: false, is_translation_enabled: false, profile_background_color: "FFF1E0", profile_background_image_url: "http://abs.twimg.com/images/themes/theme1/bg.png", profile_image_url_https: "https://pbs.twimg.com/profile_images/931156393108885504/EqEMtLhM_normal.jpg", profile_banner_url: "https://pbs.twimg.com/profile_banners/18949452/1581526592", profile_image_extensions: { mediaStats: { r: { missing: nil }, ttl: -1 } }, profile_banner_extensions: {}, blocking: false, blocked_by: false, want_retweets: false, advertiser_account_type: "none", profile_interstitial_type: "", business_profile_state: "none", translator_type: "none", followed_by: false, ext: { highlightedLabel: { ttl: -1 } }, require_some_consent: false }, token: "117" }]>
                # rubocop:enable Layout/LineLength
              end

              line do
                plain "   to eq "
                # rubocop:disable Layout/LineLength
                alpha %<[{ user_id: "18949452", user: { id: 18949452, name: "Financial Times", screen_name: "FT", location: "London", entities: { url: { urls: [{ url: "http://t.co/dnhLQpd9BY", expanded_url: "http://www.ft.com/", display_url: "ft.com", indices: [0, 22] }] }, description: { urls: [{ url: "https://t.co/5BsmLs9y1Z", expanded_url: "http://FT.com", indices: [65, 88] }] } }, listed_count: 37009, created_at: "Tue Jan 13 19:28:24 +0000 2009", favourites_count: 38, utc_offset: nil, time_zone: nil, geo_enabled: false, verified: true, statuses_count: 273860, media_count: 51044, contributors_enabled: false, is_translator: false, is_translation_enabled: false, profile_background_color: "FFF1E0", profile_background_image_url_https: "https://abs.twimg.com/images/themes/theme1/bg.png", profile_background_tile: false, profile_image_url: "http://pbs.twimg.com/profile_images/931156393108885504/EqEMtLhM_normal.jpg", profile_image_url_https: "https://pbs.twimg.com/profile_images/931156393108885504/EqEMtLhM_normal.jpg", profile_banner_url: "https://pbs.twimg.com/profile_banners/18949452/1581526592", profile_image_extensions: { mediaStats: { r: { missing: nil }, ttl: -1 } }, profile_banner_extensions: {}, blocking: false, blocked_by: false, want_retweets: false, advertiser_account_type: "none", advertiser_account_service_levels: [], profile_interstitial_type: "", business_profile_state: "none", translator_type: "none", followed_by: false, ext: { highlightedLabel: { ttl: -1 } }, require_some_consent: false }, token: "117" }]>
                # rubocop:enable Layout/LineLength
              end
            },
            diff: proc {
              plain_line %|  [|
              plain_line %|    {|
              plain_line %|      user_id: "18949452",|
              plain_line %|      user: {|
              plain_line %|        id: 18949452,|
              plain_line %|        name: "Financial Times",|
              plain_line %|        screen_name: "FT",|
              plain_line %|        location: "London",|
              beta_line  %|+       url: "http://t.co/dnhLQpd9BY",|
              plain_line %|        entities: {|
              plain_line %|          url: {|
              plain_line %|            urls: [|
              gamma_line %|              # ...|
              plain_line %|            ]|
              plain_line %|          },|
              plain_line %|          description: {|
              plain_line %|            urls: [|
              plain_line %|              {|
              gamma_line %|                # ...|
              alpha_line %|-               expanded_url: "http://FT.com",|
              beta_line  %|+               display_url: "FT.com",|
              plain_line %|                indices: [|
              plain_line %|                  65,|
              plain_line %|                  88|
              plain_line %|                ]|
              plain_line %|              }|
              plain_line %|            ]|
              plain_line %|          }|
              plain_line %|        },|
              beta_line  %|+       protected: false,|
              gamma_line %|        # ...|
              alpha_line %|-       profile_background_image_url_https: "https://abs.twimg.com/images/themes/theme1/bg.png",|
              alpha_line %|-       profile_background_tile: false,|
              alpha_line %|-       profile_image_url: "http://pbs.twimg.com/profile_images/931156393108885504/EqEMtLhM_normal.jpg",|
              beta_line  %|+       profile_background_image_url: "http://abs.twimg.com/images/themes/theme1/bg.png",|
              plain_line %|        profile_image_url_https: "https://pbs.twimg.com/profile_images/931156393108885504/EqEMtLhM_normal.jpg",|
              plain_line %|        profile_banner_url: "https://pbs.twimg.com/profile_banners/18949452/1581526592",|
              plain_line %|        profile_image_extensions: {|
              gamma_line %|          # ...|
              plain_line %|        },|
              plain_line %|        profile_banner_extensions: {},|
              plain_line %|        blocking: false,|
              plain_line %|        blocked_by: false,|
              plain_line %|        want_retweets: false,|
              plain_line %|        advertiser_account_type: "none",|
              alpha_line %|-       advertiser_account_service_levels: [],|
              gamma_line %|        # ...|
              plain_line %|      },|
              plain_line %|      token: "117"|
              plain_line %|    }|
              plain_line %|  ]|
            },
          )

          expect(program).
            to produce_output_when_run(expected_output).
            in_color(color_enabled)
        end
      end
    end

    context "if diff_elision_enabled is set to false"
  end
end
