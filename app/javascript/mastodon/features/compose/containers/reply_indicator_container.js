import { connect } from 'react-redux';
import { cancelReplyCompose, cancelQuoteCompose } from '../../../actions/compose';
import { makeGetStatus } from '../../../selectors';
import ReplyIndicator from '../components/reply_indicator';

const makeMapStateToProps = () => {
  const getStatus = makeGetStatus();

  const mapStateToProps = (state, props) => ({
    status: getStatus(state, { id: state.getIn(['compose', props.quote ? 'quote_from' : 'in_reply_to']) }),
    quote: props.quote,
  });

  return mapStateToProps;
};

const mapDispatchToProps = dispatch => ({

  onCancel (quote) {
    dispatch(quote ? cancelQuoteCompose() : cancelReplyCompose());
  },

});

export default connect(makeMapStateToProps, mapDispatchToProps)(ReplyIndicator);
