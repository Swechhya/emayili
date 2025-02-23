test_that("to: set/get", {
  msg <- envelope() %>% to("bob@gmail.com")
  expect_equal(msg$header$To$values[[1]], address("bob@gmail.com"))
  expect_equal(to(msg)[[1]], address("bob@gmail.com"))
})

test_that("to: set multiple recipients", {
  recipients <- c(address("bob@gmail.com"), address("alice@yahoo.com"))

  expect_equal(
    envelope() %>% to("bob@gmail.com, alice@yahoo.com") %>% to(),
    recipients
  )
  expect_equal(
    envelope() %>% to("bob@gmail.com", "alice@yahoo.com") %>% to(),
    recipients
  )
  expect_equal(
    envelope() %>% to(c("bob@gmail.com", "alice@yahoo.com")) %>% to(),
    recipients
  )
})

test_that("from: set/get", {
  msg <- envelope() %>% from("craig@gmail.com")
  expect_equal(from(msg), address("craig@gmail.com"))
})

test_that("cc: set/get", {
  msg <- envelope() %>% cc("bob@gmail.com")
  expect_equal(cc(msg), address("bob@gmail.com"))
})

test_that("bcc: set/get", {
  msg <- envelope() %>% bcc("bob@gmail.com")
  expect_equal(bcc(msg), address("bob@gmail.com"))
})

test_that("reply: set/get", {
  msg <- envelope() %>% reply("craig@gmail.com")
  expect_equal(reply(msg), address("craig@gmail.com"))
})

test_that("sender: set/get", {
  msg <- envelope() %>% sender("craig@gmail.com")
  expect_equal(sender(msg), address("craig@gmail.com"))
})
